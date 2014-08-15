package saml

import javax.jcr.Node
import javax.jcr.Property

import com.mongodb.casbah.Imports._
import com.mongodb.casbah.commons.conversions.scala._
import saml.jcr.rawFromProperty
import saml.jcr.iteratorFromRangeIterator

/**
 * author: saml
 */
package object mongo {
  RegisterJodaTimeConversionHelpers()

  case class Mongo(uri: String = "mongodb://localhost/") {
    lazy val client = MongoClient(MongoClientURI(uri))
  }

  //this recurses into node. do not apply it on large node tree.
  def asDoc(node: Node): MongoDBObject = {
    val properties: Iterator[Property] = node.getProperties
    val keyVals: List[(String, Any)] = properties.map(prop => (prop.getName, rawFromProperty(prop))).toList

    val name = ("_name" -> node.getName)
    val doc = MongoDBObject(keyVals)

    val children = node.getNodes.map(asDoc).toList
    if (children.isEmpty) doc += name
    else doc += (name, "_children" -> children)
  }
}
