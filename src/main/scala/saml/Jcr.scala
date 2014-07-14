package saml

/**
 * author: saml
 */
case class Jcr(url: String = "http://localhost:4502/crx/server", workspace: String = "crx.default",
               username: String = "admin", password: String = "admin") {
  private def getRepository() = {

  }

}
