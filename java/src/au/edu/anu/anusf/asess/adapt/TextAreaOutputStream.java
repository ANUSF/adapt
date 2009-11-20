package au.edu.anu.anusf.asess.adapt;

import java.awt.Font;
import java.io.IOException;
import java.io.OutputStream;

import javax.swing.JComponent;
import javax.swing.JScrollBar;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingUtilities;

/**
 * @author Olaf Delgado
 * @version $Id:$
 */
public class TextAreaOutputStream extends OutputStream {
	final private JTextArea output;
    final private StringBuffer buffer;
    final private JScrollPane scrollPane;
	final private JScrollBar vscroll;
	private char last_seen = '\0';

    public TextAreaOutputStream(final int height, final int width) {
        buffer = new StringBuffer(128);
    	output = new JTextArea(height, width);
    	output.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 12));
		scrollPane = new JScrollPane(output,
				JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
				JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
		vscroll = scrollPane.getVerticalScrollBar();
		scrollPane.setBackground(null);
    }
    
    public TextAreaOutputStream() {
    	this(24, 80);
    }
    
    public void write(int b) throws IOException {
        final char c = (char) b;
		if (c == '\n' || c == '\r') {
			if (last_seen != '\r') {
				buffer.append('\n');
				flush();
			}
		} else if (c == '\t') {
			buffer.append(c);
		} else if (c < 0x20) {
			buffer.append('^');
			buffer.append((char) (c + 0x40));
		} else if (!Character.isISOControl(c)) {
			buffer.append(c);
		}
		if (buffer.length() > 1023) {
            flush();
        }
        last_seen = c;
    }
    
    public void flush() {
        output.append(buffer.toString());
        buffer.delete(0, buffer.length());
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                vscroll.setValue(vscroll.getMaximum());
            }
        });
    }
    
    public JComponent getComponent() {
    	return scrollPane;
    }
    
    public String getText() {
    	return output.getText();
    }
}
