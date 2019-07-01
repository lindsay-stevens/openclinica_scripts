<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 OpenClinica-ODM1-3-0-OC1.xsd">
    <xsl:output method="text" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:variable name="dobExist" select="//odm:SubjectData/@OpenClinica:DateOfBirth" />
    <xsl:variable name="yobExist" select="//odm:SubjectData/@OpenClinica:YearOfBirth" />
    <xsl:variable name="sexExist" select="//odm:SubjectData/@OpenClinica:Sex" />
    <xsl:variable name="uniqueIdExist" select="//odm:SubjectData/@OpenClinica:UniqueIdentifier" />
    <xsl:variable name="subjectStatusExist" select="//odm:SubjectData/@OpenClinica:Status" />
    <xsl:variable name="secondaryIdExist" select="//odm:SubjectData/@OpenClinica:SecondaryID"/>
    <xsl:variable name="vLower" select="'abcdefghijklmnopqrstuvwxyz0123456789'"/>
    <xsl:variable name="vUpper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'"/>
    <xsl:template match="/">
        <xsl:for-each select="odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef">
            <xsl:variable name="vitemgrouprefOID">
                <xsl:value-of select="@OID"/>
            </xsl:variable>
            <xsl:variable name="vFormName">
                <xsl:value-of select="substring-before(/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef/odm:ItemGroupRef[@ItemGroupOID=$vitemgrouprefOID]/../@Name,' -')"/>
            </xsl:variable>
            <xsl:variable name="vItemGroupName">
                <xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$vitemgrouprefOID]/@Name"/>
            </xsl:variable>
            <xsl:variable name="ItemGroupOID" select="@OID"/>
            <xsl:variable name="inClinicalData" select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]"/>
            <xsl:variable name="uItemGroupName">
                <xsl:call-template name="capitalise">
                    <xsl:with-param name="rawtxt" select="$vItemGroupName"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="uFormName">
                <xsl:call-template name="capitalise">
                    <xsl:with-param name="rawtxt" select="$vFormName"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$inClinicalData">
                <xsl:call-template name="processtable">
                    <xsl:with-param name="ItemGroupOID" select="@OID"/>
                    <xsl:with-param name="vItemGroupName" select="$uItemGroupName"/>
                    <xsl:with-param name="vFormName" select="$uFormName"/>
                </xsl:call-template>
                <xsl:call-template name="variableLabels">
                    <xsl:with-param name="ItemGroupOID" select="@OID"/>
                    <xsl:with-param name="vItemGroupName" select="$uItemGroupName"/>
                    <xsl:with-param name="vFormName" select="$uFormName"/>
                </xsl:call-template>
                <xsl:call-template name="processtable_factor">
                    <xsl:with-param name="ItemGroupOID" select="@OID"/>
                    <xsl:with-param name="vItemGroupName" select="$uItemGroupName"/>
                    <xsl:with-param name="vFormName" select="$uFormName"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
<xsl:template name="processtable">
<xsl:param name="vFormName"/>
<xsl:param name="vItemGroupName"/>
<xsl:param name="ItemGroupOID"/>
<xsl:variable name="vsinglequote">'</xsl:variable>
<xsl:variable name="vbackslashsinglequote">\'</xsl:variable>	
<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/> &lt;- data.frame(SubjectID=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:StudySubjectID"/>'</xsl:for-each>),
ProtocolID=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>
<xsl:variable name="studyOID" select="../../../../@StudyOID"/>
<xsl:variable name="studyElement" select="//odm:Study[@OID = $studyOID]"/>
<xsl:variable name="protocolName" select="$studyElement/odm:GlobalVariables/odm:ProtocolName"/>'<xsl:value-of select="$protocolName" />'</xsl:for-each>)<xsl:if test="$sexExist">,
Sex=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:Sex"/>'</xsl:for-each>)</xsl:if><xsl:if test="$dobExist">,
DateOfBirth=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:DateOfBirth"/>'</xsl:for-each>)</xsl:if><xsl:if test="$yobExist">,
YearOfBirth=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:YearOfBirth"/>'</xsl:for-each>)</xsl:if><xsl:if test="$uniqueIdExist">,
PersonID=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:UniqueIdentifier"/>'</xsl:for-each>)</xsl:if><xsl:if test="$secondaryIdExist">,
SecondaryID=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:SecondaryID"/>'</xsl:for-each>)</xsl:if><xsl:if test="$subjectStatusExist">,
Status=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../../@OpenClinica:Status"/>'</xsl:for-each>)</xsl:if>,
EventName=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vStudyEventOID">
<xsl:value-of select="../../@StudyEventOID"/>
</xsl:variable>
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:StudyEventDef[@OID=$vStudyEventOID]/@Name"/>'</xsl:for-each>),
EventStatus=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../@OpenClinica:Status"/>'</xsl:for-each>),
EventStartDate=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../@OpenClinica:StartDate"/>'</xsl:for-each>),
EventEndDate=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../@OpenClinica:EndDate"/>'</xsl:for-each>),
EventLocation=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../../@OpenClinica:StudyEventLocation"/>'</xsl:for-each>),
SubjectAgeAtEvent=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vSubjectAgeAtEvent">
<xsl:value-of select="../../@OpenClinica:SubjectAgeAtEvent"/>
</xsl:variable>
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="$vSubjectAgeAtEvent"/>'</xsl:for-each>),
CRFName=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vFormOID">
<xsl:value-of select="../@FormOID"/>
</xsl:variable>
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:FormDef[@OID=$vFormOID]/@Name"/>'</xsl:for-each>),
CRFStatus=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="../@OpenClinica:Status"/>'</xsl:for-each>),
CRFInterviewDate=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vStartDate">
<xsl:value-of select="../@OpenClinica:InterviewDate"/>
</xsl:variable>
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="$vStartDate"/>'</xsl:for-each>),
CRFInterviewerName=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:variable name="vStartDate">
<xsl:value-of select="../@OpenClinica:InterviewerName"/>
</xsl:variable>
<xsl:if test="position()>1">,
</xsl:if>'<xsl:value-of select="$vStartDate"/>'</xsl:for-each>),		
StudyEventRepeatKey=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>
<xsl:choose>
<xsl:when test="../../@StudyEventRepeatKey">
<xsl:value-of select="../../@StudyEventRepeatKey"/>
</xsl:when>
<xsl:otherwise>NA</xsl:otherwise>
</xsl:choose>
</xsl:for-each>),
ItemGroupRepeatKey=c(
<xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
<xsl:if test="position()>1">,
</xsl:if>
<xsl:choose>
<xsl:when test="@ItemGroupRepeatKey">
<xsl:value-of select="@ItemGroupRepeatKey"/>
</xsl:when>
<xsl:otherwise>NA</xsl:otherwise>
</xsl:choose>
</xsl:for-each>)<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef">
    <xsl:variable name="vExists" select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]"/>
    <xsl:if test="$vExists">
        <xsl:variable name="vItemOID">
            <xsl:value-of select="@ItemOID"/>
        </xsl:variable>
        <xsl:call-template name="outputVariable">
            <xsl:with-param name="ItemGroupOID" select="$ItemGroupOID" />
            <xsl:with-param name="vItemOID" select="$vItemOID" />
            <xsl:with-param name="vDataType" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@DataType"/>
            <xsl:with-param name="vName" select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@Name"/>
        </xsl:call-template>
    </xsl:if>
</xsl:for-each>);
</xsl:template>
<xsl:template name="variableLabels">
<xsl:param name="vFormName"/>
<xsl:param name="vItemGroupName"/>
<xsl:param name="ItemGroupOID"/>
<xsl:variable name="vsinglequote">'</xsl:variable>
<xsl:variable name="vbackslashsinglequote">\'</xsl:variable>
attributes(<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>)$variable.labels &lt;- c(
"Subject ID", "Site ID"<xsl:if test="$sexExist">, "Sex"</xsl:if>
<xsl:if test="$dobExist">, "Birthdate"</xsl:if><xsl:if test="$yobExist">, "Year of birth"</xsl:if>
<xsl:if test="$uniqueIdExist">, "Person ID"</xsl:if><xsl:if test="$secondaryIdExist">, "Secondary ID"</xsl:if>
<xsl:if test="$subjectStatusExist">, "Subject status"</xsl:if>
<xsl:text>, "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"</xsl:text>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef">
    <xsl:variable name="vItemOID">
        <xsl:value-of select="@ItemOID"/>
    </xsl:variable>
    <xsl:text>&#10;,"</xsl:text>
    <xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef[@OID=$vItemOID]/@Comment"/>
    <xsl:text>"</xsl:text>
</xsl:for-each>);
</xsl:template>

<xsl:template name="processtable_factor">
<xsl:param name="vFormName"/>
<xsl:param name="vItemGroupName"/>
<xsl:param name="ItemGroupOID"/>
<xsl:variable name="vsinglequote">'</xsl:variable>
<xsl:variable name="vbackslashsinglequote">\'</xsl:variable>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList">
<xsl:variable name="vCodeListOID">
<xsl:value-of select="@OID"/>
</xsl:variable>
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemDef/odm:CodeListRef[@CodeListOID=$vCodeListOID]">
<xsl:variable name="vItemOID"><xsl:value-of select="../@OID"/></xsl:variable>
<xsl:variable name="vItemName"><xsl:value-of select="../@Name"/></xsl:variable>
<xsl:variable name="vDataType"><xsl:value-of select="../@DataType"/></xsl:variable>
<xsl:if test="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:ItemGroupDef[@OID=$ItemGroupOID]/odm:ItemRef[@ItemOID=$vItemOID]">
codes &lt;- c(
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$vCodeListOID]/odm:CodeListItem">
<xsl:if test="position()>1">,
</xsl:if><xsl:choose>
<xsl:when test="$vDataType='text'">'<xsl:value-of select="@CodedValue"/>'</xsl:when>
<xsl:otherwise><xsl:value-of select="@CodedValue"/></xsl:otherwise>
</xsl:choose>
</xsl:for-each>);
levs &lt;- c(
<xsl:for-each select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$vCodeListOID]/odm:CodeListItem">
<xsl:if test="position()>1">,
</xsl:if>
<xsl:variable name="vFieldValue">
<xsl:value-of select="odm:Decode/odm:TranslatedText"/>
</xsl:variable><xsl:variable name="doublequote">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$vFieldValue" />
<xsl:with-param name="replace" select="$vsinglequote" />
<xsl:with-param name="by" select="$vbackslashsinglequote" />
</xsl:call-template>
</xsl:variable>
<xsl:variable name="cleanfield">
<xsl:call-template name="replace">
<xsl:with-param name="text" select="$doublequote" />
<xsl:with-param name="replace" select="'&#10;'" />
<xsl:with-param name="by" select="' '" />
</xsl:call-template>
</xsl:variable>'<xsl:value-of select="$cleanfield"/>'</xsl:for-each>);
<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>$f.<xsl:value-of select="$vItemName"/>&lt;-factor(match(<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>$<xsl:value-of select="$vItemName"/>,codes),levels=1:length(codes),labels=levs);
w&lt;-which(names(<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>)=="<xsl:value-of select="$vItemName"/>");
l&lt;- dim(<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>)[2];
if (!is.null(w) &amp; !is.null(l)){} else{if(w&lt;(l-1))<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>&lt;-<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(<xsl:value-of select="concat($vFormName,'_',$vItemGroupName)"/>$f.<xsl:value-of select="$vItemName"/>, "label") &lt;- "<xsl:value-of select="/odm:ODM/odm:Study/odm:MetaDataVersion/odm:CodeList[@OID=$vCodeListOID]/@Name"/>"
</xsl:if>
</xsl:for-each>
</xsl:for-each>
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

<xsl:template name="replace_date">
    <xsl:param name="text" />
    <xsl:choose>
        <xsl:when test="contains($text, 'Jan')">
            <xsl:value-of select="concat(substring($text,8),'-01-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Feb')">
            <xsl:value-of select="concat(substring($text,8),'-02-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Mar')">
            <xsl:value-of select="concat(substring($text,8),'-03-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Apr')">
            <xsl:value-of select="concat(substring($text,8),'-04-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'May')">
            <xsl:value-of select="concat(substring($text,8),'-05-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Jun')">
            <xsl:value-of select="concat(substring($text,8),'-06-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Jul')">
            <xsl:value-of select="concat(substring($text,8),'-07-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Aug')">
            <xsl:value-of select="concat(substring($text,8),'-08-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Sep')">
            <xsl:value-of select="concat(substring($text,8),'-09-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Oct')">
            <xsl:value-of select="concat(substring($text,8),'-10-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Nov')">
            <xsl:value-of select="concat(substring($text,8),'-11-',substring($text,1,2))" />
        </xsl:when>
        <xsl:when test="contains($text, 'Dec')">
            <xsl:value-of select="concat(substring($text,8),'-12-',substring($text,1,2))" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="capitalise">
    <xsl:param name="rawtxt" />
    <xsl:value-of select="concat(
translate(
translate(substring($rawtxt,1,1),$vLower,$vUpper),
translate(translate(substring($rawtxt,1,1),$vLower,$vUpper),$vUpper,''),
''
),
translate(
translate(substring($rawtxt,2),$vUpper,$vLower),
translate(translate(substring($rawtxt,2),$vUpper,$vLower),$vLower,''),
''
))"/>
</xsl:template>

<xsl:template name="outputVariable">
    <xsl:param name="ItemGroupOID"/>
    <xsl:param name="vItemOID"/>
    <xsl:param name="vName"/>
    <xsl:param name="vSource"/>
    <xsl:param name="vDataType"/>
    
    <xsl:variable name="vsinglequote">'</xsl:variable>
    <xsl:variable name="vbackslashsinglequote">\'</xsl:variable>
    <xsl:text>,&#10;</xsl:text>
    <xsl:value-of select="$vName"/>
    <xsl:text>=c(&#10;</xsl:text>
    <xsl:for-each select="/odm:ODM/odm:ClinicalData/odm:SubjectData/odm:StudyEventData/odm:FormData/odm:ItemGroupData[@ItemGroupOID=$ItemGroupOID]">
        <xsl:if test="position()>1">
            <xsl:text>,&#10;</xsl:text>
        </xsl:if>
        <xsl:choose>            
            <xsl:when test="odm:ItemData[@ItemOID=$vItemOID]/@Value">                
                <xsl:variable name="vFieldValue">
                    <xsl:value-of select="odm:ItemData[@ItemOID=$vItemOID]/@Value"/>
                </xsl:variable>
                <xsl:choose>                    
                    <xsl:when test="$vDataType='text' or $vDataType='partialDate'">
                        <xsl:variable name="singlequote">
                            <xsl:call-template name="replace">
                                <xsl:with-param name="text" select="$vFieldValue" />
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
                        </xsl:variable>
                        <xsl:text>'</xsl:text>
                        <xsl:value-of select="$cleanfield"/>
                        <xsl:text>'</xsl:text>
                    </xsl:when>
                    <xsl:when test="$vDataType='date'">
                        <xsl:variable name="cleandate">
                            <xsl:call-template name="replace_date">
                                <xsl:with-param name="text" select="$vFieldValue" />
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:text>as.Date("</xsl:text>
                        <xsl:value-of select="$cleandate"/>"<xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$vFieldValue"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>NA</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
</xsl:template>
</xsl:stylesheet>