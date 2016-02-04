<?xml version="1.0" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
                xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 OpenClinica-ODM1-3-0-OC1.xsd">
    
    <!-- Output types for result-document instructions. -->
    <xsl:output encoding="utf-8"
                indent="yes"
                method="xml"
                name="xml" />
    <xsl:output encoding="utf-8"
                indent="no"
                method="text"
                name="plain"
                omit-xml-declaration="yes" />
    
    <!-- Suppress unmatched nodes. -->
    <xsl:template match="text()"/>
    
    <!-- Get the parent study oid, which is listed first. -->
    <xsl:variable name="study_oid"
                  select="substring(//odm:Study[position()=1]/@OID, 3)"/>
    
    <!-- Index of objects for lookup. -->
    <xsl:key name="event-name"
             match="odm:StudyEventDef"
             use="@OID"/>
    <xsl:key name="item-name"
             match="odm:ItemDef"
             use="@OID"/>
    
    <!-- Catch-all template that feeds 3 result documents.
            HTML-encoded characters in use: &#xa; (newline), &#9; (tab),
                &quot; (double quote),  &lt; (less than), &gt; (greater than).
      -->
    <xsl:template match="/*">
        <!-- data.xml : the raw data. -->
        <xsl:result-document format="xml"
                             href="data.xml">
            <xsl:element name="{$study_oid}">
                <xsl:apply-templates mode="data"
                                     select="//odm:ItemGroupData"/>
            </xsl:element>
        </xsl:result-document>
        
        <!-- map.xml : instructions for how to read the raw data. -->
        <xsl:result-document format="xml"
                             href="map.xml">
            <xsl:element name="SXLEMAP">
                <xsl:attribute name="version">
                    <xsl:value-of select="'1.2'"/>
                </xsl:attribute>
                <xsl:apply-templates mode="map"
                                     select="odm:Study/odm:MetaDataVersion/odm:ItemGroupDef"/>
            </xsl:element>
        </xsl:result-document>
        
        <!-- load.sas : script to read the raw data, and apply formats. -->
        <xsl:result-document format="plain"
                             href="load.sas">
            <xsl:value-of select="concat('FILENAME ', $study_oid, ' &quot;data.xml&quot;;&#xa;')"/>
            <xsl:value-of select="'FILENAME map &quot;map.xml&quot;;&#xa;'"/>
            <xsl:value-of select="concat('LIBNAME ', $study_oid, ' xml xmlmap=map access=readonly;&#xa;')"/>
            <xsl:value-of select="concat('PROC DATASETS LIBRARY=', $study_oid, ';&#xa;')"/>
            <xsl:value-of select="'COPY OUT=work; RUN; PROC FORMAT;&#xa;&#xa;'"/>
            <xsl:apply-templates mode="format"
                                 select="odm:Study/odm:MetaDataVersion/odm:CodeList"/>
            <xsl:value-of select="'RUN;&#xa;'"/>
            <xsl:apply-templates mode="format"
                                 select="odm:Study/odm:MetaDataVersion/odm:ItemGroupDef"/>
        </xsl:result-document>
    </xsl:template>
    
    <!--
        
        1. data.xml templates.
        
      -->
    
    <!-- Return ClinicalData arranged as rows of ItemGroup data. -->
    <xsl:template match="odm:ItemGroupData"
                  mode="data">
        <xsl:element name="{@ItemGroupOID}">
            <xsl:element name="SubjectID">
                <xsl:value-of select="ancestor::odm:SubjectData/@OpenClinica:StudySubjectID"/>
            </xsl:element>
            <xsl:element name="StudyEvent">
                <xsl:value-of select="key('event-name',ancestor::odm:StudyEventData/@StudyEventOID)/@Name"/>
            </xsl:element>
            <xsl:element name="StudyEventRepeatKey">
                <xsl:value-of select="ancestor::odm:StudyEventData/@StudyEventRepeatKey"/>
            </xsl:element>
            <xsl:element name="ItemGroupRepeatKey">
                <xsl:value-of select="@ItemGroupRepeatKey"/>
            </xsl:element>
            <xsl:apply-templates mode="data"
                                 select="odm:ItemData"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Return ClinicalData item values as ItemGroup elements -->
    <xsl:template match="odm:ItemData"
                  mode="data">
        <xsl:element name="{@ItemOID}">
            <xsl:value-of select="@Value"/>
        </xsl:element>
    </xsl:template>
    
    <!--
        
        2. map.xml templates.
        
      -->
    
    <!-- Row header data for item group data, PATH node is set dynamically.-->
    <xsl:variable name="sas_rowheaders">
        <row name="SubjectID">
            <TYPE>character</TYPE>
            <DATATYPE>string</DATATYPE>
            <LENGTH>50</LENGTH>
        </row>
        <row name="StudyEvent">
            <TYPE>character</TYPE>
            <DATATYPE>string</DATATYPE>
            <LENGTH>255</LENGTH>
        </row>
        <row name="StudyEventRepeatKey">
            <TYPE>numeric</TYPE>
            <DATATYPE>integer</DATATYPE>
        </row>
        <row name="ItemGroupRepeatKey">
            <TYPE>numeric</TYPE>
            <DATATYPE>integer</DATATYPE>
        </row>
    </xsl:variable>
    
    <!-- Return the ItemGroup TABLE map elements. -->
    <xsl:template match="odm:ItemGroupDef"
                  mode="map">
        <xsl:element name="TABLE">
            <xsl:attribute name="name">
                <xsl:value-of select="@OID"/>
            </xsl:attribute>
            <xsl:element name="TABLE-PATH">
                <xsl:attribute name="syntax">
                    <xsl:value-of select="'XPATH'"/>
                </xsl:attribute>
                <xsl:value-of select="concat('/', $study_oid, '/', @OID)"/>
            </xsl:element>
            <xsl:apply-templates select="$sas_rowheaders/row"
                                 mode="map">
                <xsl:with-param name="itemgroup"
                                select="@OID"/>
            </xsl:apply-templates>
    
            <xsl:apply-templates select="odm:ItemRef"
                                 mode="map"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Return row header data using above data.-->
    <xsl:template match="row"
                  mode="map">
        <xsl:param name="itemgroup"/>
        <xsl:element name="COLUMN">
            <xsl:attribute name="Name">
                <xsl:value-of select="@name"/>
            </xsl:attribute>
            <xsl:element name="PATH">
                <xsl:value-of select="concat('/', $study_oid, '/', $itemgroup, '/', @name)"/>
            </xsl:element>
            <xsl:copy-of copy-namespaces="no"
                         select="*"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Mapping of OpenClinica datatypes to SAS types and datatypes.-->
    <xsl:variable name="sas_typemap">
        <row oc="date">
            <TYPE>character</TYPE>
            <DATATYPE>date</DATATYPE>
        </row>
        <row oc="float">
            <TYPE>numeric</TYPE>
            <DATATYPE>double</DATATYPE>
        </row>
        <row oc="integer">
            <TYPE>numeric</TYPE>
            <DATATYPE>integer</DATATYPE>
        </row>
        <row oc="partialDate">
            <TYPE>character</TYPE>
            <DATATYPE>string</DATATYPE>
            <LENGTH>20</LENGTH>
        </row>
        <row oc="text">
            <TYPE>character</TYPE>
            <DATATYPE>string</DATATYPE>
        </row>
    </xsl:variable>
    
    <!-- Return the Item COLUMN map elements. -->
    <xsl:template match="odm:ItemRef"
                  mode="map">
        <xsl:variable name="item_group_oid"
                      select="ancestor::odm:ItemGroupDef/@OID"/>
        <xsl:variable name="itemdef"
                      select="key('item-name', @ItemOID)"/>
        <xsl:variable name="typemap"
                      select="$sas_typemap"/>
        <xsl:element name="COLUMN">
            <xsl:attribute name="Name">
                <xsl:value-of select="$itemdef/@SASFieldName"/>
            </xsl:attribute>
            <xsl:element name="PATH">
                <xsl:value-of select="concat('/', $study_oid, '/', $item_group_oid, '/', @ItemOID)"/>
            </xsl:element>
            <xsl:copy-of copy-namespaces="no"
                         select="$typemap/row[@oc=$itemdef/@DataType]/*"/>
            <xsl:choose>
                <xsl:when test="$itemdef/@DataType='text' and $itemdef/@Length &gt; 255">
                    <xsl:element name="LENGTH">
                        <xsl:value-of select="255"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$itemdef/@DataType='text' and $itemdef/@Length &lt; 256">
                    <xsl:element name="LENGTH">
                        <xsl:value-of select="$itemdef/@Length"/>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <!--
        
        3. format.sas templates.
        
      -->
    <!-- remove rogue spaces from this plain text output. -->
    <xsl:strip-space elements="odm:CodeList"/>
    
    <!-- Return CodeList VALUE command header and footer fragments. 
            If the CodeList is text, prefix the name with a "$".
      -->
    <xsl:template match="odm:CodeList"
                  mode="format">
        <xsl:value-of select="'VALUE '"/>
        <xsl:if test="@DataType='text'">
            <xsl:value-of select="'&#36;'"/>
        </xsl:if>
        <xsl:value-of select="concat(@OID, '_')"/>
        <xsl:apply-templates mode="format"/>
        <xsl:value-of select="';&#xa;'"/>
    </xsl:template>
    
    <!-- Return CodeList VALUE command format items. 
            If the CodeList is text, wrap the labelled value in quotes.
      -->
    <xsl:template match="odm:CodeListItem"
                  mode="format">
        <xsl:value-of select="'&#xa;&#9;'"/>
        <xsl:choose>
            <xsl:when test="ancestor::odm:CodeList/@DataType='text'">
                <xsl:value-of select="concat('&quot;',@CodedValue, '&quot;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@CodedValue"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="concat('=&quot;',odm:Decode/odm:TranslatedText/text(), '&quot;')"/>
    </xsl:template>
    
    <!-- Identify ItemGroups with Items that have CodeLists. -->
    <xsl:template match="odm:ItemGroupDef"
                  mode="format">
        <xsl:apply-templates mode="format"
                             select="odm:ItemRef[key('item-name', @ItemOID)/odm:CodeListRef]"/>
    </xsl:template>
    
    <!-- Return DATA, SET, FORMAT commands to apply formats to items. -->
    <xsl:template match="odm:ItemRef"
                  mode="format">
        <xsl:variable name="item_group_oid"
                      select="ancestor::odm:ItemGroupDef/@OID"/>
        <xsl:variable name="itemdef"
                      select="key('item-name', @ItemOID)"/>
        <xsl:value-of select="concat('&#xa;&#xa;DATA ', $item_group_oid, ';&#xa;')"/>
        <xsl:value-of select="concat('SET ', $item_group_oid, ';&#xa;')"/>
        <xsl:value-of select="concat('FORMAT ', $itemdef/@SASFieldName, ' ')"/>
        <xsl:value-of select="concat($itemdef/odm:CodeListRef/@CodeListOID, '_; RUN;')"/>
    </xsl:template>
</xsl:stylesheet>