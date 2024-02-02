<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fn="http://framenet.icsi.berkeley.edu">
<xsl:output method="text" />
<!-- This XSL file transforms fulltextIndex XML into a page
     listing Corpora, which expand to list their Documents. The
     expanding links are handled by Javascript.
     First the XSL transforms the body then some Javascript
     is executed onload. -->
<xsl:template match="/fn:fulltextIndex">[
	<xsl:for-each select='fn:corpus'><xsl:sort select='@description' order='ascending' /><xsl:if test='position() > 1'>,</xsl:if>{
		<xsl:variable name='menuNum' select='position()' />
		<xsl:variable name='corpName' select='@name' />
        "description": "<xsl:value-of select='@description' />",
        "documents": [
			<xsl:for-each select='fn:document'><xsl:sort select='@description' order='ascending' /><xsl:if test='position() > 1'>,</xsl:if>{
				<xsl:variable name='docName' select='@name' />
                <!-- "path": "<xsl:value-of select='fulltext/{$corpName}__{$docName}.xml' />", -->
                "path": "fulltext/<xsl:value-of select='$corpName' />__<xsl:value-of select='$docName' />.xml",
                "description": "<xsl:value-of select='@description' />"
	        }</xsl:for-each>
        ]
    }</xsl:for-each>
]</xsl:template>
</xsl:stylesheet>
