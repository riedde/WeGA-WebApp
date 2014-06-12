<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:wega="http://xquery.weber-gesamtausgabe.de/webapp/functions/utilities"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0">
    <xsl:output encoding="UTF-8" method="html" omit-xml-declaration="yes" indent="no"/>
    <xsl:param name="createToc" select="false()"/>
    <xsl:param name="createSecNos" select="false()"/>
    <xsl:param name="collapseBlock" select="false()"/>
    <xsl:param name="uri"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space
        elements="tei:cell tei:p tei:hi tei:persName tei:rs tei:workName tei:characterName tei:placeName tei:code tei:eg tei:item tei:head tei:date"/>
    <xsl:include href="common_link.xsl"/>
    <xsl:include href="common_main.xsl"/>
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:text">
        <xsl:element name="div">
            <xsl:attribute name="id" select="'docText'"/>
            <xsl:if test="$createToc">
                <xsl:call-template name="createToc">
                    <xsl:with-param name="lang" select="$lang"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates select=".//tei:div[@xml:lang=$lang]"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:div">
        <xsl:variable name="uniqueID">
            <xsl:choose>
                <xsl:when test="@xml:id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="generate-id()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="collapseable" as="xs:string+" select="('abstract', 'toc')"/>
        <xsl:if test="$collapseBlock and @type = $collapseable">
            <xsl:element name="span">
                <xsl:attribute name="class" select="'toggleBlock internalLink'"/>
                <xsl:attribute name="onclick"
                    select="concat('$(&#34;', $uniqueID, '&#34;).toggle()')"/>
                <xsl:text>[</xsl:text>
                <xsl:value-of select="wega:getLanguageString(@type, $lang)"/>
                <xsl:text> +-]</xsl:text>
            </xsl:element>
        </xsl:if>
        <xsl:element name="div">
            <xsl:attribute name="id" select="$uniqueID"/>
            <xsl:if test="$collapseBlock and @type = $collapseable">
                <xsl:attribute name="style" select="'display:none;'"/>
                <xsl:attribute name="class" select="string-join((@type, 'collapseBlock'), ' ')"/>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:head[not(@type='sub')]">
        <xsl:choose>
            <xsl:when test="$createToc">
                <!-- Überschrift h2 für Editionsrichtlinien und Weber-Biographie -->
                <xsl:element name="{concat('h', count(ancestor::tei:div) +1)}">
                    <xsl:attribute name="id">
                        <xsl:choose>
                            <xsl:when test="@xml:id">
                                <xsl:value-of select="@xml:id"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="generate-id()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="$createSecNos">
                    <xsl:call-template name="createSecNo">
                        <xsl:with-param name="div" select="parent::tei:div"/>
                        <xsl:with-param name="lang" select="$lang"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <!-- Überschrift h1 für Indexseite und Impressum -->
                <xsl:element name="{concat('h', count(ancestor::tei:div))}">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:head[@type='sub']">
        <xsl:element name="h3">
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:p">
        <xsl:element name="p">
            <xsl:apply-templates select="@xml:id"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:code">
        <xsl:element name="span">
            <xsl:apply-templates select="@xml:id"/>
            <xsl:attribute name="class" select="'code'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:eg">
        <xsl:element name="div">
            <xsl:apply-templates select="@xml:id"/>
            <xsl:attribute name="class" select="'eg'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:figure" priority="1">
        <xsl:variable name="digilibDir" select="wega:getOption('digilibDir')"/>
        <xsl:variable name="figureHeight" select="'195'"/>
        <xsl:variable name="figureWidth" select="'150'"/>
        <xsl:element name="img">
            <xsl:apply-templates select="@xml:id"/>
            <xsl:attribute name="src"
                select="concat($digilibDir, replace(tei:graphic/@url, '/db/images/', ''), '&amp;dh=', $figureHeight, '&amp;mo=q2')"/>
            <xsl:attribute name="title"
                select="tei:figDesc/tei:title[@xml:lang = $lang and @level = 'a']"/>
            <xsl:attribute name="alt"
                select="tei:figDesc/tei:title[@xml:lang = $lang and @level = 'a']"/>
            <xsl:attribute name="width" select="$figureWidth"/>
            <xsl:attribute name="height" select="$figureHeight"/>
            <xsl:attribute name="class" select="'teaserImage'"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:address">
        <xsl:element name="ul">
            <xsl:apply-templates select="@xml:id"/>
            <xsl:attribute name="class" select="'contactAddress'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:addrLine">
        <xsl:element name="li">
            <xsl:apply-templates select="@xml:id"/>
            <xsl:choose>
                <xsl:when test="@n='telephone'">
                    <xsl:value-of select="concat(wega:getLanguageString('tel',$lang), ': ', .)"/>
                </xsl:when>
                <xsl:when test="@n='fax'">
                    <xsl:value-of select="concat(wega:getLanguageString('fax',$lang), ': ', .)"/>
                </xsl:when>
                <xsl:when test="@n='email'">
                    <xsl:variable name="encryptedEmail"
                        select="string-join(for $i in wega:encryptString(., ()) return string($i), ' ')"/>
                    <xsl:element name="span">
                        <xsl:attribute name="class" select="'ema'"/>
                        <xsl:attribute name="onclick">
                            <xsl:value-of
                                select="concat('javascript:decEma(&#34;',$encryptedEmail,'&#34;)')"
                            />
                        </xsl:attribute>
                        <xsl:value-of select="wega:obfuscateEmail(.)"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- Create section numbers for headings   -->
    <xsl:template name="createSecNo">
        <xsl:param name="div"/>
        <xsl:param name="lang"/>
        <xsl:param name="dot" select="false()"/>
        <xsl:if test="$div/parent::tei:div">
            <xsl:call-template name="createSecNo">
                <xsl:with-param name="div" select="$div/parent::tei:div"/>
                <xsl:with-param name="lang" select="$lang"/>
                <xsl:with-param name="dot" select="true()"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="count($div/preceding-sibling::tei:div/tei:head[ancestor::tei:div/@xml:lang=$lang]) + 1"/>
        <xsl:if test="$dot">
            <xsl:text>. </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Create table of contents   -->
    <xsl:template name="createToc">
        <xsl:param name="lang"/>
        <xsl:element name="div">
            <xsl:attribute name="id" select="'toc'"/>
            <xsl:element name="h2">
                <xsl:value-of select="wega:getLanguageString('toc', $lang)"/>
            </xsl:element>
            <xsl:element name="ul">
                <xsl:for-each
                    select="//tei:text//tei:head[not(@type='sub') and ancestor::tei:div/@xml:lang = $lang]">
                    <xsl:element name="li">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('#', generate-id())"/>
                            </xsl:attribute>
                            <xsl:if test="$createSecNos">
                                <xsl:call-template name="createSecNo">
                                    <xsl:with-param name="div" select="parent::tei:div"/>
                                    <xsl:with-param name="lang" select="$lang"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>