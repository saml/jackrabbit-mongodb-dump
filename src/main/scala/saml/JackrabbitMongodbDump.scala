package saml

import javax.jcr.Node

import com.mongodb.casbah.Imports._
import saml.jcr.Connection
import saml.jcr.allNodes
import saml.mongo.Mongo
import saml.mongo.asDoc

import scala.util.matching.Regex

/**
 * author: saml
 */
case class JackrabbitMongodbDump(jackrabbit: Connection, collection: MongoCollection) {
  def bench[T](f: => T): (T, Long) = {
    val t = System.currentTimeMillis()
    val result = f
    (result, System.currentTimeMillis() - t)
  }

  // returns number of dumps, milliseconds it took.
  def start(path: String, regex: Regex): (Int, Long) = {
    val (count,took) = bench(dump(path, regex))
    println(s"Imported ${count}. Took ${took/1000.0} secs.")
    (count,took)
  }

  def dump(path: String, regex: Regex): Int = {
    val root = jackrabbit.nodeAt(path)
    val isMatching: Node => Boolean = isPathMatching(regex)
    allNodes(root).filter(isMatching).foldLeft(0)(insertAndCount)
  }

  private def isPathMatching(regex: Regex)(node: Node): Boolean =
    regex.findFirstIn(node.getPath).isDefined

  private def insertAndCount(count: Int, node: Node): Int = {
    insert(node)
    count + 1
  }

  def insert(node: Node) = {
    collection.insert(asDoc(node) += ("_path" -> node.getPath))
  }
}

object JackrabbitMongodbDump {
  def dumpNymag(cqHost: String = "localhost:4502", cqUsername: String = "author", cqPassword: String = "author",
           mongoUri: String = "mongodb://localhost/",
           dbName: String = "cq_dump", collectionName: String = "pages") = {
    val cqUrl = s"http://${cqHost}/crx/server"
    val collection = Mongo(mongoUri).client(dbName)(collectionName)
    val cqConnection = Connection(cqUrl, username = cqUsername, password = cqPassword)
    val path = "/content/nymag/daily"
    println(s"Dumping ${cqHost}${path} to ${mongoUri} ${dbName}.${collectionName}")
    JackrabbitMongodbDump(cqConnection, collection).start(path, """/\d\d\d\d/\d\d/[^/]+/jcr:content$""".r)
  }

}
