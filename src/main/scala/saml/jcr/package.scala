package saml

import javax.jcr.Node
import javax.jcr.Property
import javax.jcr.PropertyType
import javax.jcr.RangeIterator
import javax.jcr.SimpleCredentials
import javax.jcr.Value
import javax.jcr.query.Query

import org.apache.jackrabbit.commons.JcrUtils
import org.joda.time.DateTime

/**
 * author: saml
 */
package object jcr {
  implicit def iteratorFromRangeIterator[A <: RangeIterator, B](iter: A): Iterator[B] = new Iterator[B] {
    def hasNext(): Boolean = iter.hasNext
    def next(): B = iter.next().asInstanceOf[B]
  }

  def allNodes(node: Node): Iterator[Node] =
    Iterator.single(node) ++ node.getNodes().flatMap(allNodes)

  def rawFromProperty(prop: Property) = {
    if (prop.isMultiple) prop.getValues.map(rawFromValue)
    else rawFromValue(prop.getValue)
  }

  def rawFromValue(value: Value) = {
    value.getType match {
      case PropertyType.BOOLEAN => value.getBoolean
      case PropertyType.LONG => value.getLong
      case PropertyType.DOUBLE => value.getDouble
      case PropertyType.DECIMAL => value.getDecimal
      case PropertyType.DATE => new DateTime(value.getDate)
      case PropertyType.STRING => value.getString
      case PropertyType.BINARY => value.getString //heheheh maybe base64 encode
      case otherwise => value.getString
    }
  }

  case class Connection(url: String = "http://localhost:4502/crx/server", workspace: String = "crx.default",
                        username: String = "admin", password: String = "admin") {

    lazy val repo = JcrUtils.getRepository(url)
    lazy val rawSession = repo.login(new SimpleCredentials(username, password.toCharArray))
    lazy val repoWorkspace = rawSession.getWorkspace
    lazy val queryManager = repoWorkspace.getQueryManager

    def nodeAt(path: String): Node = rawSession.getNode(path)

    def xpath(statement: String, limit: Long = 0, offset: Long = 0): Iterator[Node] = {
      val query = queryManager.createQuery(statement, Query.XPATH)
      modifyQuery(query, limit, offset)
      query.execute().getNodes
    }

  }

  private def modifyQuery(query: Query, limit: Long, offset: Long) = {
    if (limit > 0) {
      query.setLimit(limit)
    }
    if (offset > 0) {
      query.setOffset(offset)
    }

    query
  }


}
