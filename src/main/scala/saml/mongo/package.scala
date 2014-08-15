package saml

import javax.jcr.{Node, Property}

import com.mongodb.casbah.Imports._
import com.mongodb.casbah.commons.conversions.scala._
import saml.jcr._

/**
 * author: saml
 */
package object mongo {
  RegisterJodaTimeConversionHelpers()

  case class Mongo(uri: String) {
    lazy val client = MongoClient(MongoClientURI(uri))
  }

  //this recurses into node. do not apply it on large node tree.
  def asDoc(node: Node): MongoDBObject = {
    val properties: Iterator[Property] = node.getProperties
    val keyVals: List[(String, Any)] = properties.map(prop => (prop.getName, rawFromProperty(prop))).toList
    MongoDBObject(keyVals) += ("_children" -> node.getNodes.map(asDoc).toList, "_name" -> node.getName)
  }
}
