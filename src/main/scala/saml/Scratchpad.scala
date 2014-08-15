package saml

/**
 * author: saml
 */
object Scratchpad {
  val INT = 0
  val BOOL = 1
  val STR = 2

  // mock of Java API http://www.day.com/maven/jsr170/javadocs/jcr-2.0/javax/jcr/Value.html
  case class Value(ty: Int, intVal: Option[Int] = None, boolVal: Option[Boolean] = None, strVal: Option[String] = None) {
    def getInt = intVal.get
    def getStr = strVal.get
    def getBool = boolVal.get
  }

  def rawValue[T](value: Value): T = {
    val x = value.ty match {
      case INT => value.getInt
      case STR => value.getStr
      case BOOL => value.getBool
    }
    x.asInstanceOf[T]
  }

  val x: String = rawValue[String](Value(STR, strVal = Some("hello")))
  println(x)
  val y: String = rawValue[String](Value(INT, intVal = Some(42)))
  println(y)






}
