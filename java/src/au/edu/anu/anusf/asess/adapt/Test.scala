package au.edu.anu.anusf.asess.adapt

case class Test(something: AnyRef) {
	def typeOf = something.getClass.getName
}
