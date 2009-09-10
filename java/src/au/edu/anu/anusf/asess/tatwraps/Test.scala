package au.edu.anu.anusf.asess.tatwraps

case class Test(something: AnyRef) {
	def typeOf = something.getClass.getName
}
