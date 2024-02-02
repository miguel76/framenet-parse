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
                    "frameName": "<xsl:value-of select='@frameName'/>",
                    "frameId": "<xsl:value-of select='@frameID'/>",
                    "annotationStatus": "<xsl:value-of select='@status'/>",
                    "frameElements": [
                        <xsl:for-each select="fn:layer[@name='FE']/fn:label"><xsl:if test='position() > 1'>,</xsl:if>{
                            <xsl:if test='@start and @end'>"lexeme": "<xsl:value-of select='substring($sentenceTxt, @start + 1, @end + 1 - @start)' />",</xsl:if>
                            <xsl:if test='@start'>"start": <xsl:value-of select='@start' />,</xsl:if>
                            <xsl:if test='@end'>"end": <xsl:value-of select='@end' />,</xsl:if>
                            "id": "<xsl:value-of select='@feID'/>",
                            "name": "<xsl:value-of select='@name'/>"
                        }</xsl:for-each>
                    ]
                }</xsl:for-each>
            ]
        }</xsl:for-each>
    ]
}
<xsl:if test="$mode='document'">
</xsl:if>
<xsl:if test="$mode='createdby'">
    //<![CDATA[
    var cBys = new Array();
    var cBy = '';
    //]]>
    <xsl:for-each select="fn:sentence/fn:annotationSet/fn:layer[@name='FE'or@name='Target']/fn:label/@cBy">
        <xsl:sort select='.' order='ascending' />
        cBy = "<xsl:value-of select='.' />";
        //<![CDATA[
        if (!cBys.contains(cBy))
            cBys.push(cBy);
        //]]>
    </xsl:for-each>
    //<![CDATA[
    document.getElementById('cby').innerHTML += '<b>Annotator ID(s): </b>' + cBys.join(', ');
    //]]>
</xsl:if>
<xsl:if test="$mode='sentence'">
    //<![CDATA[
    var sent;
    var sentOrig;
    var charLabelMap;
    var rank2, rank3;
    var sc_name;
    // [colorSent, noColorSent]
    var finalStr = ["", ""];
    //]]>
    var sentId = "<xsl:value-of select='$sentId' />";
    var frameName = "<xsl:value-of select='@frame'/>";
    <xsl:for-each select="//fn:sentence/fn:annotationSet[@ID=$sentId]">
        var cursentId = "<xsl:value-of select='@ID' />";
        //<![CDATA[
        // have to escape all quotes in the sent[0] first, using template at bottom
        //]]>
        <xsl:variable name="processSent">
            <xsl:call-template name="cleanQuote">
            <xsl:with-param name="string">
                <xsl:value-of select='normalize-space(../fn:text)' />
            </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        sentOrig = "<xsl:value-of select='$processSent' />";
        //<![CDATA[
        // [colorSent, noColorSent] for each rank 1-3
        sent = [["", ""], ["", ""], ["", ""]];
        // simulate 6 maps (for each rank 1-3 and for color/noColor)
        // with simple javascript object properties
        charLabelMap = [[new Object(), new Object()],
            [new Object(), new Object()], [new Object(), new Object()]];
        rank2 = false; // assume no rank 2 at first
        rank3 = false; // assume no rank 3 at first
        //]]>

        <!-- get labels and insert into charLabelMap -->
        <xsl:for-each select="fn:layer[@name='FE'or@name='Target'or@name='Noun'or@name='Adj'or@name='Verb']/fn:label">
            <xsl:sort select="../@name" order="ascending" />
            <!-- ^ make sure Target layer always comes last so it can be overridden by an FE -->
            labelName = "<xsl:value-of select='@name' />";
            fgColor = "<xsl:value-of select='@fgColor' />";
            bgColor = "<xsl:value-of select='@bgColor' />";
            rank = <xsl:value-of select='../@rank' />;
            //<![CDATA[
            if (rank == 2)
                rank2 = true;
            else if (rank == 3)
                rank3 = true;
            else if (rank > 3) {
                // shouldn't happen: no case yet, but script could be edited to accomodate
                sentOrig += " ERROR: LABEL " + labelName + " HAS RANK > 3. THIS IS NOT " +
                    "HANDLED YET (NO SUCH CASE WHEN SCRIPT WAS WRITTEN BUT COULD BE ADDED)";
            }

            // get the label data and store it in charLabelMap
            //]]>
            <xsl:if test="@start">
                start = "<xsl:value-of select='@start' />";
                <!-- add 1 (just the way char values work out later) and make it a string -->
                end = <xsl:value-of select='@end' /> + 1 + "";
                <xsl:if test="../@name = 'Target'">
                    //<![CDATA[
                    // color
                    insertMapValue(charLabelMap[0][0], start, "<TARGET><span class='Target'>", false);
                    insertMapValue(charLabelMap[0][0], end, "<TARGET></span>", true);
                    // no color
                    insertMapValue(charLabelMap[0][1], start, "<TARGET><span class='italic'>", true);
                    insertMapValue(charLabelMap[0][1], end, "<TARGET></span><sup>Target</sup>", false);
                    //]]>
                </xsl:if>
                <xsl:if test="../@name = 'FE'">
                    //<![CDATA[
                    if (rank < 4) { // should always be true
                        // color
                        insertMapValue(charLabelMap[rank-1][0], start,
                            "<span style='color:#" + fgColor + ";background-color:#" + bgColor + ";'>", false);
                        insertMapValue(charLabelMap[rank-1][0], end, "</span>", true);

                        // no color
                        insertMapValue(charLabelMap[rank-1][1], start,
                            "[<sub>" + labelName + "</sub>", true);
                        insertMapValue(charLabelMap[rank-1][1], end, "]", false);
                    }
                    //]]>
                </xsl:if>
                <xsl:if test="../@name = 'Noun'">
                    //<![CDATA[
                    // color
                    if (labelName == "Gov")
                        insertMapValue(charLabelMap[0][0], start, "<span class='Gov'>", false);
                    else if (labelName == "X")
                        insertMapValue(charLabelMap[0][0], start, "<span class='X'>", false);
                    insertMapValue(charLabelMap[0][0], end, "</span>", true);

                    // no color
                    if (labelName == "Gov") {
                        insertMapValue(charLabelMap[0][1], start, "[", false);
                        insertMapValue(charLabelMap[0][1], end, "]<sup>Gov</sup>", true);
                    }
                    else if (labelName == "X") {
                        insertMapValue(charLabelMap[0][1], start, "{", false);
                        insertMapValue(charLabelMap[0][1], end, "}<sup>X</sup>", true);
                    }
                    //]]>
                </xsl:if>
                <xsl:if test="@name = 'Supp' and (../@name = 'Noun' or ../@name='Verb' or ../@name='Adj')">
                    //<![CDATA[
                    // color
                    insertMapValue(charLabelMap[0][0], start, "<span class='italic'>", false);
                    insertMapValue(charLabelMap[0][0], end, "</span>", true);

                    // no color
                    insertMapValue(charLabelMap[0][1], start, "[", false);
                    insertMapValue(charLabelMap[0][1], end, "]<sup>Supp</sup>", true);
                    //]]>
                </xsl:if>
                <xsl:if test="@name = 'Ctrlr' and (../@name = 'Noun' or ../@name='Verb' or ../@name='Adj')">
                    //<![CDATA[
                    // color
                    insertMapValue(charLabelMap[0][0], start, "<span class='italic'>", false);
                    insertMapValue(charLabelMap[0][0], end, "</span>", true);

                    // no color
                    insertMapValue(charLabelMap[0][1], start, "[", false);
                    insertMapValue(charLabelMap[0][1], end, "]<sup>Ctrlr</sup>", true);
                    //]]>
                </xsl:if>
            </xsl:if>
            <xsl:if test="not(@start)">
                itype = "<xsl:value-of select='@itype' />";
                //<![CDATA[
                // color
                insertMapValue(charLabelMap[0][0], "itype",
                    "<span style='color:#" + fgColor + ";background-color:#" + bgColor + ";'>", true);
                insertMapValue(charLabelMap[0][0], "itype", itype + "</span>", true);

                // no color
                insertMapValue(charLabelMap[0][1], "itype",
                    "[<sub>" + labelName + "</sub>" + itype + "]", true);
                //]]>
            </xsl:if>
        </xsl:for-each>

        //<![CDATA[
        // apply color labels in charLabelMap to sent
        sent = applyLabelsToSent(charLabelMap, sent, sentOrig, 0);

        // apply non-color labels in charLabelMap to sent
        sent = applyLabelsToSent(charLabelMap, sent, sentOrig, 1);

        // construct finalStr from sent
        // color
        finalStr[0] += sent[0][0];
        var invisSpan = "<br /><span class='invisible'>"
        if (rank2)
            finalStr[0] += invisSpan + "[X] " + sent[1][0] + "</span>";
        if (rank3)
            finalStr[0] += invisSpan + "[X] " + sent[2][0] + "</span>";

        // no color
        finalStr[1] += sent[0][1];
        if (rank2)
            finalStr[1] += invisSpan + "[X] " + sent[1][1] + "</span>";
        if (rank3)
            finalStr[1] += invisSpan + "[X] " + sent[2][1] + "</span>";
        //]]>
    </xsl:for-each>
    //<![CDATA[
    colorSent = finalStr[0];
    noColorSent = finalStr[1];

    // before the sentence, insert the [X] link
    pretext = "[<a href='javascript:removeSent(" + sentId + ")'>X</a>] ";

    // load the constructed text into two divs, one with color
    // and one with just mark up
    document.getElementById('sent' + sentId + 'C_On').innerHTML += pretext + colorSent;
    document.getElementById('sent' + sentId + 'C_Off').innerHTML += pretext + noColorSent;

    showSents();
    //]]>
</xsl:if>
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
</xsl:stylesheet>
