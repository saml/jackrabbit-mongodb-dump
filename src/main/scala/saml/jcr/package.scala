package saml

import javax.jcr.query.Query
import javax.jcr.{SimpleCredentials, Node, RangeIterator, Session}

import org.apache.jackrabbit.commons.JcrUtils

/**
 * author: saml
 */
package object jcr {
  def iteratorFromRangeIterator[A <: RangeIterator, B](iter: A): Iterator[B] = new Iterator[B] {
    def hasNext(): Boolean = iter.hasNext
    def next(): B = iter.next().asInstanceOf[B]
  }

  case class Connection(url: String = "http://localhost:4502/crx/server", workspace: String = "crx.default",
                        username: String = "admin", password: String = "admin") {

    lazy val repo = JcrUtils.getRepository(url)
    lazy val rawSession = repo.login(new SimpleCredentials(username, password.toCharArray))
    lazy val repoWorkspace = rawSession.getWorkspace
    lazy val queryManager = repoWorkspace.getQueryManager

    def xpath(statement: String, limit: Long = 0, offset: Long = 0): Iterator[Node] = {
      val query = queryManager.createQuery(statement, Query.XPATH)
      modifyQuery(query, limit, offset)
      iteratorFromRangeIterator(query.execute().getNodes)
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
