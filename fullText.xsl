<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:fn="http://framenet.icsi.berkeley.edu">
<xsl:output method="text" />
<!-- This XSL file transforms fullText XML into FullText Reports.
     First the browser executes the default XSL block ($mode='') to generate a
     HTML/Javascript file with three modes: the main mode (mode=''), which sets
     up the HTML frameset and frames; the top frame mode (mode='document'), which
     displays the Document text with some annotation and links to sentences; and
     the bottom frame sentence mode (mode='sentence'), which displays annotated
     sentences.
     The document mode and sentence mode call the XSLT processor on the
     'document', 'createdBy', and 'sentence' XSL blocks and evaluate
     the resulting Javascript. -->
<xsl:param name='mode'></xsl:param>
<xsl:param name='sentId'></xsl:param>
<xsl:template match="/fn:fullTextAnnotation">
{
    "corpusId": "<xsl:value-of select='fn:header/fn:corpus/@ID'/>",
    "corpusName": "<xsl:value-of select='fn:header/fn:corpus/@name'/>",
    "corpusDescription": "<xsl:value-of select='fn:header/fn:corpus/@description'/>",
    "documentId": "<xsl:value-of select='fn:header/fn:corpus/fn:document/@ID'/>",
    "documentName": "<xsl:value-of select='fn:header/fn:corpus/fn:document//@name'/>",
    "documentDescription": "<xsl:value-of select='fn:header/fn:corpus/fn:document//@description'/>",
    "sentences": [
        <xsl:for-each select="fn:sentence"><xsl:if test='position() > 1'>,</xsl:if>{
            <!-- have to escape all quotes in the sent first, using template at bottom -->
            <xsl:variable name="sentenceTxt">
                <xsl:call-template name="cleanQuote">
                    <xsl:with-param name="string">
                        <xsl:value-of select='normalize-space(fn:text)' />
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <!-- "sentenceText": "<xsl:value-of select='replace($sentenceTxt, " ([.,;:])", "$1")' />", -->
            "sentenceText": "<xsl:value-of select='$sentenceTxt' />",
            "currentParagraph": "<xsl:value-of select='@paragNo' />",
            "frameAnnotations": [
                <xsl:for-each select="fn:annotationSet[@frameName]"><xsl:if test='position() > 1'>,</xsl:if>{
                    <!-- <xsl:sort select="../@name" order="ascending" /> -->
                    "id": "<xsl:value-of select='@ID'/>",
                    "frameName": "<xsl:value-of select='@frameName'/>",
                    "frameId": "<xsl:value-of select='@frameID'/>",
                    "luName": "<xsl:value-of select='@luName'/>",
                    "luId": "<xsl:value-of select='@luID'/>",
                    "annotationStatus": "<xsl:value-of select='@status'/>",
                    "frameElements":
                        <xsl:call-template name="labelList">
                            <xsl:with-param name="layerName" select="'FE'" />
                            <xsl:with-param name="sentenceTxt" select='$sentenceTxt' />
                        </xsl:call-template>,
                    "targets":
                        <xsl:call-template name="labelList">
                            <xsl:with-param name="layerName" select="'Target'" />
                            <xsl:with-param name="sentenceTxt" select='$sentenceTxt' />
                        </xsl:call-template>
                }</xsl:for-each>
            ]
        }</xsl:for-each>
    ]
}
</xsl:template>

<!-- borrowed code for escaping quotes in strings -->
<xsl:template name="cleanQuote">
	<xsl:param name="string" />
	<xsl:if test="contains($string, '&#x22;')">
		<xsl:value-of select="substring-before($string, '&#x22;')" />\"<xsl:call-template name="cleanQuote">
                <xsl:with-param name="string">
					<xsl:value-of select="substring-after($string, '&#x22;')" />
                </xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	<xsl:if test="not(contains($string, '&#x22;'))">
		<xsl:value-of select="$string" />
	</xsl:if>
</xsl:template>

<xsl:template name="labelList">
	<xsl:param name="layerName" />
	<xsl:param name="sentenceTxt" />
    [
        <xsl:for-each select="fn:layer[@name=$layerName]/fn:label"><xsl:if test='position() > 1'>,</xsl:if>{
            <xsl:call-template name="labelInfo">
                <xsl:with-param name="sentenceTxt" select='$sentenceTxt' />
            </xsl:call-template>
        }</xsl:for-each>
    ]
</xsl:template>

<xsl:template name="labelInfo">
	<xsl:param name="sentenceTxt" />
    <xsl:if test='@start and @end'>"lexeme": "<xsl:value-of select='substring($sentenceTxt, @start + 1, @end + 1 - @start)' />",</xsl:if>
    <xsl:if test='@start'>"start": <xsl:value-of select='@start' />,</xsl:if>
    <xsl:if test='@end'>"end": <xsl:value-of select='@end' />,</xsl:if> 
    <xsl:if test='@feID'>"id": <xsl:value-of select='@feID' />,</xsl:if> 
    "name": "<xsl:value-of select='@name'/>"
</xsl:template>
</xsl:stylesheet>
