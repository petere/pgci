<?xml version='1.0'?>

<!-- Print out http(s) and ftp links from DocBook document -->

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version='1.0'>

  <xsl:output method="text"/>

  <xsl:template match="*[starts-with(@id, 'release-7-') or starts-with(@id, 'release-8-0') or starts-with(@id, 'release-8-1') or starts-with(@id, 'release-8-2')]">
  </xsl:template>

  <xsl:template match="ulink">
    <xsl:choose>
      <xsl:when test="starts-with(@url, 'http:') or starts-with(@url, 'https:') or starts-with(@url, 'ftp:')">
        <xsl:value-of select="@url"/>
        <xsl:text>
</xsl:text>
      </xsl:when>
      <xsl:when test="starts-with(@url, 'mailto:') or starts-with(@url, 'news:')">
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">Unrecognized URL scheme: "<xsl:value-of select="@url"/>"</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="text()">
  </xsl:template>
</xsl:stylesheet>
