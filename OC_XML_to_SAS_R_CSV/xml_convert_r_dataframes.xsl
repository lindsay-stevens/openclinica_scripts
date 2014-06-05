<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 OpenClinica-ODM1-3-0-OC1.xsd">
<xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>
<xsl:template match="/">
<xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef">
<xsl:variable name="vitemgrouprefOID">
<xsl:value-of select="@OID"/>
</xsl:variable>
<xsl:variable name="vFormName">
<xsl:value-of select="substring-before(/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef/odm:ItemGroupRef[@ItemGroupOID=$vitemgrouprefOID]/../@Name,' -')"/>
</xsl:variable>
<xsl:variable name="vTableName">
<xsl:call-template name="get_tablename">
<xsl:with-param name="formname" select="$vFormName"/>
<xsl:with-param name="groupname" select="@Name"/>
<xsl:with-param name="groupid" select="@OID"/>
</xsl:call-template>
</xsl:variable>
<xsl:call-template name="processtable">
<xsl:with-param name="TableName" select="$vTableName"/>
<xsl:with-param name="ItemGroupOID" select="@OID"/>
</xsl:call-template>
</xsl:for-each>
</xsl:template>
<xsl:template name="processtable">
<xsl:param name="TableName"/>
<xsl:param name="ItemGroupOID"/>
<xsl:variable name="vsinglequote">'</xsl:variable>
<xsl:variable name="vbackslashsinglequote">\'</xsl:variable>
<xsl:variable name="vbackslash">\</xsl:variable>
<xsl:variable name="vbackslashbackslash">\\</xsl:variable>
<xsl:choose>
<xsl:when test="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:value-of select="$TableName"/> &lt;- data.frame(SubjectID=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]"><xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:StudySubjectID"/>'</xsl:for-each>),
EventName=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vStudyEventOID"><xsl:value-of select="../../@StudyEventOID"/></xsl:variable><xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:StudyEventDef[@OID=$vStudyEventOID]/@Name"/>'</xsl:for-each>),
StudyEventRepeatKey=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>
<xsl:choose>
<xsl:when test="../../@StudyEventRepeatKey"><xsl:value-of select="../../@StudyEventRepeatKey"/></xsl:when>
<xsl:otherwise>NA</xsl:otherwise>
</xsl:choose>
</xsl:for-each>),
CRFName=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vFormOID"><xsl:value-of select="../@FormOID"/></xsl:variable><xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef[@OID=$vFormOID]/@Name"/>'</xsl:for-each>),
ItemGroupRepeatKey=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>
<xsl:choose>
<xsl:when test="@ItemGroupRepeatKey"><xsl:value-of select="@ItemGroupRepeatKey"/></xsl:when>
<xsl:otherwise>NA</xsl:otherwise>
</xsl:choose>
</xsl:for-each>)</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$TableName"/> &lt;- data.frame(SubjectID=character(),EventName=character(),StudyEventRepeatKey=numeric(),CRFName=character(),ItemGroupRepeatKey=numeric()</xsl:otherwise>
</xsl:choose>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef">
<xsl:variable name="vItemOID">
<xsl:value-of select="@ItemOID"/>
</xsl:variable>
<xsl:variable name="vDataType">
<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@DataType"/>
</xsl:variable>,
<xsl:choose>
<xsl:when test="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@Name"/>=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if><xsl:choose>
<xsl:when test="odm:ItemData[@ItemOID=$vItemOID]">
<xsl:variable name="vFieldValue">
<xsl:value-of select="odm:ItemData[@ItemOID=$vItemOID]/@Value"/>
</xsl:variable>
<xsl:choose><xsl:when test="($vDataType='text') or ($vDataType='partialDate')">
<xsl:variable name="fieldbackslash">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$vFieldValue" />
<xsl:with-param name="replace" select="$vbackslash" />
<xsl:with-param name="by" select="$vbackslashbackslash" />
</xsl:call-template>
</xsl:variable>
<xsl:variable name="singlequote">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$fieldbackslash" />
<xsl:with-param name="replace" select="$vsinglequote" />
<xsl:with-param name="by" select="$vbackslashsinglequote" />
</xsl:call-template>
</xsl:variable>
<xsl:variable name="cleanfield">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$singlequote" />
<xsl:with-param name="replace" select="'&#10;'" />
<xsl:with-param name="by" select="' '" />
</xsl:call-template>
</xsl:variable>'<xsl:value-of select="$cleanfield"/>'</xsl:when>
<xsl:when test="$vDataType='date'"><xsl:choose><xsl:when test="$vFieldValue=''">NA</xsl:when><xsl:otherwise>as.Date("<xsl:value-of select="$vFieldValue"/>")</xsl:otherwise></xsl:choose></xsl:when>
<xsl:otherwise><xsl:choose><xsl:when test="$vFieldValue=''">NA</xsl:when><xsl:otherwise><xsl:value-of select="$vFieldValue"/></xsl:otherwise></xsl:choose></xsl:otherwise></xsl:choose>
</xsl:when>
<xsl:otherwise>NA</xsl:otherwise>
</xsl:choose>
</xsl:for-each>)</xsl:when>
<xsl:otherwise>
<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@Name"/>=<xsl:choose><xsl:when test="$vDataType='text'">character()</xsl:when><xsl:when test="$vDataType='date'">as.Date(character())</xsl:when><xsl:otherwise>numeric()</xsl:otherwise></xsl:choose></xsl:otherwise>
</xsl:choose>
</xsl:for-each>,stringsAsFactors=FALSE);<xsl:text>&#10;</xsl:text>
</xsl:template>
<xsl:template name="replace">
<xsl:param name="text" />
<xsl:param name="replace" />
<xsl:param name="by" />
<xsl:choose>
<xsl:when test="contains($text, $replace)">
<xsl:value-of select="substring-before($text,$replace)" />
<xsl:value-of select="$by" />
<xsl:call-template name="replace">
<xsl:with-param name="text"
select="substring-after($text,$replace)" />
<xsl:with-param name="replace" select="$replace" />
<xsl:with-param name="by" select="$by" />
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text" />
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:include href="xml_convert_dynamic_lookup.xsl"/> 
</xsl:stylesheet>