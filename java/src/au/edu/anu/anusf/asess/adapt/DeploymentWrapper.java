package au.edu.anu.anusf.asess.adapt;

import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Properties;
import java.util.jar.JarEntry;
import java.util.jar.JarInputStream;

import javax.swing.JFrame;
import javax.swing.JOptionPane;

import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.nio.SelectChannelConnector;
import org.mortbay.jetty.webapp.WebAppContext;
import org.mortbay.log.Log;

/**
 * Proof-of-concept implementation for the deployment of a servlet-based web
 * application with an embedded jetty server in an executable jar.
 * 
 * The main method unpacks the enclosed war file into a fixed location relative
 * the the user's home directory, creates a database from an enclosed template
 * if none exists, then serves the application under "localhost:8080" via
 * embedded jetty.
 * 
 * @author olaf
 */
public class DeploymentWrapper {
	// -- the buffer used by the copy method
	final private byte[] buffer = new byte[1024 * 1024];
	
	// -- the classloader associated with this class
	final private ClassLoader loader = this.getClass().getClassLoader();
	
	// -- the Jetty server instance with some configuration data
	private Server server;
	final String hostname = "127.0.0.1";
	final int port = 8080;
	final URI uri = new URI("http", null, hostname, port, null, null, null);
	
	// -- application name and some file system path components
	String warName;
	String applicationBase;
	String applicationName;
	String applicationTag;
	String applicationPath;
	
	// -- GUI elements
	private JFrame controlFrame = null;
	private TextAreaOutputStream consoleWidget = null;
	
	/**
	 * At the moment, the constructor sets up and runs everything.
	 * 
	 * @throws Exception
	 */
	public DeploymentWrapper() throws Exception {
		determineApplicationName();
		showControlFrame();
		setAdaptSystemProperties();
		logSystemProperties();
		extractApplication();
		startServer();
		openBrowserFrame();
		waitForServer();
	}
	
	private void determineApplicationName() throws IOException {
		this.warName = this.contentsOf("appname.txt").trim();
		final String[] tmp = this.warName.split("-");
		this.applicationName = tmp[0];
		this.applicationTag = tmp[1];

		final String home = System.getProperty("user.home");
		this.applicationBase = joinedPath(home, this.applicationName);
		this.applicationPath =
			joinedPath(applicationBase, "releases", this.applicationTag);
	}
	
	private void showControlFrame() {
		final PrintStream syserr = System.err;
		final PrintStream sysout = System.out;
		try {
			final TextAreaOutputStream tmp = new TextAreaOutputStream();
			final PrintStream newout = new PrintStream(tmp);
			System.setErr(newout);
			System.setOut(newout);
			this.consoleWidget = tmp;
			
			this.controlFrame =
				new JFrame(this.applicationName + ": Server log");
			if (this.consoleWidget != null) {
				this.controlFrame.getContentPane()
					.add(this.consoleWidget.getComponent());
			}
			this.controlFrame.pack();
			this.controlFrame.setDefaultCloseOperation(
					JFrame.DO_NOTHING_ON_CLOSE);
			this.controlFrame.addWindowListener(new WindowAdapter() {
				public void windowClosing(final WindowEvent event) {
					confirmProgramExit();
				}
			});
			this.controlFrame.setVisible(true);
		} catch (final Throwable ex) {
			System.setErr(syserr);
			System.setOut(sysout);
			Log.warn("Could not open a logging window.");
		}
	}
	
	private void confirmProgramExit() {
		final int answer = JOptionPane.showConfirmDialog(this.controlFrame,
				"Stop server and exit?", null, JOptionPane.YES_NO_OPTION);
		if (answer != JOptionPane.YES_OPTION) return;
		
		try {
			stopServer();
			final String name = joinedPath(this.applicationBase, "Server.log");
			saveConsoleOutput(name);
			JOptionPane.showMessageDialog(this.controlFrame,
					"Wrote server log to " + name);
		} catch (final Throwable ex) {
		}
		System.exit(0);
	}
	
	private void saveConsoleOutput(final String name)
	throws FileNotFoundException {
		final PrintStream s = new PrintStream(new FileOutputStream(name));
		s.print(consoleWidget.getText());
		s.close();
	}
	
	private void logSystemProperties() {
    	final Properties props = System.getProperties();
    	final List<String> pkeys = new ArrayList<String>();
    	for (final Object key: props.keySet()) {
    		pkeys.add(String.valueOf(key));
    	}
    	Collections.sort(pkeys);
    	Log.info("System properties:");
    	for (final String key: pkeys) {
    		Log.info(String.format("    %-32s    %s",
    				key, props.getProperty(key)));
    	}
	}
	
	private void extractApplication() throws IOException {
		Log.info("Extracting web application to " + this.applicationPath);
		this.extractJar(this.applicationPath, this.warName + ".war");
	}

	private void setAdaptSystemProperties() {
		System.setProperty("adapt.is.local", "true");
	}
	
	private void startServer() throws Exception {
		Log.info("Starting server on " + this.uri);
        this.server = new Server();
        final Connector connector = new SelectChannelConnector();
        connector.setPort(this.port);
        connector.setHost(this.hostname);
        this.server.addConnector(connector);

        this.server.setHandler(new WebAppContext(this.applicationPath, "/"));
        this.server.setStopAtShutdown(true);
        this.server.start();
	}
	
	private void waitForServer() throws InterruptedException {
		if (this.server != null) this.server.join();
	}
	
	private void stopServer() throws Exception {
		if (this.server != null) {
			this.server.stop();
			waitForServer();
		}
	}
	
	private void openBrowserFrame() throws IOException {
		boolean hasDesktop = false;
		try {
			this.loader.loadClass("java.awt.Desktop");
			hasDesktop = true;
		} catch (final Throwable ex) {
		}
		if (hasDesktop) {
			hasDesktop = false;
			if (java.awt.Desktop.isDesktopSupported()) {
				final java.awt.Desktop desktop =
					java.awt.Desktop.getDesktop();
				if (desktop.isSupported(java.awt.Desktop.Action.BROWSE)) {
					Log.info("Directing default web browser to " + this.uri);
					desktop.browse(this.uri);
					hasDesktop = true;
				}
			}
		}
		if (!hasDesktop) {
			Log.warn("No Java 6 desktop support for web browsing.");
			JOptionPane.showMessageDialog(null,
					"Please direct your web browser to " + this.uri);
		}
	}
	
	/**
	 * Extracts jar contents to a given filesystem location.
	 * 
	 * @param target the base path for the unpacked contents.
	 * @param ins the name of the resource containing the jar data.
	 * @throws IOException
	 * @throws FileNotFoundException
	 */
	private void extractJar(final String target, final String jarName)
	throws IOException, FileNotFoundException
	{
		new File(target).mkdirs();
		final InputStream stream = this.loader.getResourceAsStream(jarName);
		final JarInputStream jar = new JarInputStream(stream);
		
        while (true) {
        	final JarEntry entry = jar.getNextJarEntry();
        	if (entry == null) break;
        	
        	final String name = joinedPath(target, entry.getName());
        	if (entry.isDirectory()) {
        		new File(name).mkdirs();
        	} else {
        		final FileOutputStream outs = new FileOutputStream(name);
        		copy(jar, outs);
        		outs.flush();
        		outs.close();
        	}
        }
        jar.close();
	}
	
	private String contentsOf(final String fileName) throws IOException {
		final InputStream s = this.loader.getResourceAsStream(fileName);
		final int n = s.read(this.buffer);
		return new String(this.buffer, 0, n);
	}

	/**
	 * Copies data between streams using a buffer.
	 * 
	 * @param ins the input stream.
	 * @param outs the output stream.
	 * @throws IOException
	 */
	private void copy(final InputStream ins, final OutputStream outs)
	throws IOException
	{
		while (ins.available() > 0) {
			final int n = ins.read(this.buffer);
			if (n > 0) outs.write(this.buffer, 0, n);
		}
	}
	
	private String joinedPath(final String... parts) {
		if (parts.length == 0) {
			return "";
		} else {
			final StringBuilder builder = new StringBuilder(100);
			for (String part: parts) {
				if (builder.length() > 0) builder.append(File.separator);
				builder.append(part);
			}
			return builder.toString();
		}
	}
	
	public static void main(final String[] args) throws Exception {
		new DeploymentWrapper();
	}
}
