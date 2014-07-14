package saml

import javax.jcr.SimpleCredentials

import org.apache.jackrabbit.commons.JcrUtils

/**
 * author: saml
 */
case class Jcr(url: String = "http://localhost:4502/crx/server", workspace: String = "crx.default",
               username: String = "admin", password: String = "admin") {

  lazy val repo = JcrUtils.getRepository(url)
  lazy val session = repo.login(new SimpleCredentials(username, password.toCharArray))
}
