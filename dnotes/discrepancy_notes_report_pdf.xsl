<?xml version="1.0" ?>
<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
        xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1"
        xmlns:exslt="http://exslt.org/common"
        extension-element-prefixes="exslt">
    <xsl:output indent="yes"
                encoding="utf-8"/>
    
    <!-- General structure.
         - 3 template modes.
         - Mode 1: data. Uses input ODM XML data and condenses, does lookups.
         - Mode 2: doc_bookmark. Uses data mode output to make bookmark tree.
         - Mode 3: doc_content. Uses data mode output to make pdf page content.
      -->

    <!-- Variable for output of data mode templates for pdf layout use.
         - xsl:copy returns a XTreeFragment, but a XNodeSet is needed for the 
           usual XPath things to work, so exslt:node-set function is used in 
           the PDF Layout template to do the conversion.
      -->
    <xsl:variable name="data">
        <xsl:copy>
            <xsl:apply-templates mode="data"
                                 select="/*"/>
        </xsl:copy>
    </xsl:variable>
    
    <!-- Debug template for output data mode templates.
         - Remove the mode attribute from this template. 
         - Add a mode attribute to the PDF Layout template.
         - Call the stylesheet from the command line, like so:
         java -cp saxon-8.7.jar net.sf.saxon.Transform -o out.xml in.xml this.xsl
      -->
    <xsl:template match="/"
                  mode="debug">
        <xsl:copy-of select="exslt:node-set($data)"/>
    </xsl:template>

    <!-- PDF Layout -->
    <xsl:template match="/">
        <xsl:variable name="data_nodeset"
                      select="exslt:node-set($data)"/>
        <fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format">
            <fo:layout-master-set>
                <fo:simple-page-master
                    master-name="main"
                    page-height="29.7cm"
                    page-width="21cm"
                    font-family="sans-serif"
                    margin="2cm">
                    <fo:region-body margin-top="2.5cm"/>
                    <fo:region-before extent="2cm"/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            
            <fo:bookmark-tree>
                <xsl:apply-templates mode="doc_bookmark"
                                     select="$data_nodeset"/>
            </fo:bookmark-tree>
            
            <fo:page-sequence master-reference="main">
                <fo:static-content
                    flow-name="xsl-region-before"
                    font-size="14pt"
                    font-weight="bold">
                    <fo:block>
                        <xsl:value-of select="$data_nodeset/study/study_name"/>
                        <xsl:text> Queries</xsl:text>
                    </fo:block>
                    <fo:block>
                        <fo:retrieve-marker retrieve-class-name="mark-site-name"/>
                    </fo:block>
                    <fo:block>
                        <fo:retrieve-marker retrieve-class-name="mark-subject-id"/>
                    </fo:block>
                </fo:static-content>
                <fo:flow
                    flow-name="xsl-region-body"
                    font-size="11pt">
                    <xsl:apply-templates mode="doc_content"
                                         select="$data_nodeset"/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <!-- template to suppress text output in doc_bookmark mode templates. -->
    <xsl:template match="text()"
                  mode="doc_bookmark"/>
    <!-- template to suppress text output in doc_content mode templates. -->
    <xsl:template match="text()"
                  mode="doc_content"/>

    <!-- site name bookmarks -->
    <xsl:template match="site"
                  mode="doc_bookmark">
        <fo:bookmark starting-state="hide">
            <xsl:attribute name="internal-destination">
                <xsl:value-of select="site_name"/>
            </xsl:attribute>
            <fo:bookmark-title>
                <xsl:value-of select="site_name"/>
            </fo:bookmark-title>
            <xsl:apply-templates mode="doc_bookmark"
                                 select="subject">
                <xsl:sort select="subject_id"/>
            </xsl:apply-templates>
        </fo:bookmark>
    </xsl:template>

    <!-- subject id bookmarks within sites -->
    <xsl:template match="subject"
                  mode="doc_bookmark">
        <fo:bookmark starting-state="hide">
            <xsl:attribute name="internal-destination">
                <xsl:value-of select="subject_id"/>
            </xsl:attribute>
            <fo:bookmark-title>
                <xsl:value-of select="subject_id"/>
            </fo:bookmark-title>
            <xsl:apply-templates mode="doc_bookmark"
                                 select="dnote">
                <xsl:sort select="concat(substring('000000000',1,
                    12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
            </xsl:apply-templates>
        </fo:bookmark>
    </xsl:template>

    <!-- Note id bookmarks within subjects -->
    <xsl:template match="dnote"
                  mode="doc_bookmark">
        <fo:bookmark>
            <xsl:attribute name="internal-destination">
                <xsl:value-of select="concat(substring('000000000',1,
                    12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
            </xsl:attribute>
            <fo:bookmark-title>
                <xsl:value-of select="concat(substring('000000000',1,
                    12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
            </fo:bookmark-title>
        </fo:bookmark>
    </xsl:template>

    <!-- Start a new page after each site. -->
    <xsl:template match="site"
                  mode="doc_content">
        <fo:block page-break-after="always">
            <xsl:attribute name="id">
                <xsl:value-of select="site_name"/>
            </xsl:attribute>
            <fo:marker marker-class-name="mark-site-name">
                <xsl:value-of select="site_name"/>
            </fo:marker>
            <xsl:apply-templates mode="doc_content"
                                 select="subject">
                <xsl:sort select="subject_id"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>

    <!-- Subject content blocks -->
    <xsl:template match="subject"
                  mode="doc_content">
        <fo:block page-break-after="always">
            <xsl:attribute name="id">
                <xsl:value-of select="subject_id"/>
            </xsl:attribute>
            <fo:marker marker-class-name="mark-subject-id">
                <xsl:value-of select="subject_id"/>
            </fo:marker>
            <xsl:apply-templates mode="doc_content"
                                 select="*">
                <xsl:sort
                        select="concat(substring('000000000',1,12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>

    <!-- Note content blocks within subjects. It's just a big table.-->
    <xsl:template match="dnote"
                  mode="doc_content">
        <fo:table
                table-layout="fixed"
                width="100%"
                keep-together.within-page="always"
                margin-bottom="0.5cm"
                border-width="1">
            <fo:table-column
                    column-number="1"
                    column-width="25%"/>
            <fo:table-column
                    column-number="2"
                    column-width="75%"/>
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:attribute name="id">
                                <xsl:value-of
                                        select="concat(substring('000000000',1,12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
                            </xsl:attribute>
                            <xsl:text>Note ID</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block>
                            <xsl:value-of
                                    select="concat(substring('000000000',1,12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:text>Entity Type</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block>
                            <xsl:value-of select="dn_entity_type"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:choose>
                    <xsl:when
                            test="dn_entity_type='Item' or dn_entity_type='Event'">
                        <fo:table-row>
                            <fo:table-cell border="solid black 1px"
                                           padding="2px">
                                <fo:block font-weight="bold">
                                    <xsl:text>Event Name</xsl:text>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell border="solid black 1px"
                                           padding="2px">
                                <fo:block>
                                    <xsl:value-of
                                            select="dn_entity_detail/event_name"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                            <fo:table-cell border="solid black 1px"
                                           padding="2px">
                                <fo:block font-weight="bold">
                                    <xsl:text>Event Repeat</xsl:text>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell border="solid black 1px"
                                           padding="2px">
                                <fo:block>
                                    <xsl:value-of
                                            select="dn_entity_detail/event_repeat"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                        <xsl:choose>
                            <xsl:when test="dn_entity_type='Item'">
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Form Name</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block>
                                            <xsl:value-of
                                                    select="dn_entity_detail/form_name"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Form Section</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block>
                                            <xsl:value-of
                                                    select="dn_entity_detail/form_section"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>ItemGroup Name</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block>
                                            <xsl:value-of
                                                    select="dn_entity_detail/itemgroup_name"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>ItemGroup Repeat</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block>
                                            <xsl:value-of
                                                    select="dn_entity_detail/itemgroup_repeat"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Item Name</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block>
                                            <xsl:value-of
                                                    select="dn_entity_detail/item_name"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Item Value</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block>
                                            <xsl:value-of
                                                    select="dn_entity_detail/item_value"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Item Code List Label</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px"
                                                   padding="2px">
                                        <fo:block>
                                            <xsl:value-of
                                                    select="dn_entity_detail/item_code_list_label"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="dn_entity_type='Subject'">
                        <fo:table-row>
                            <fo:table-cell border="solid black 1px"
                                           padding="2px">
                                <fo:block font-weight="bold">
                                    <xsl:text>Entity ID</xsl:text>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell border="solid black 1px"
                                           padding="2px">
                                <fo:block>
                                    <xsl:value-of select="dn_entity_id"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </xsl:when>
                </xsl:choose>
                <fo:table-row>
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:text>Note Status</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block>
                            <xsl:value-of select="dn_status"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:if
                        test="string-length(dn_description_last)>0">
                    <fo:table-row>
                        <fo:table-cell border="solid black 1px"
                                       padding="2px">
                            <fo:block font-weight="bold">
                                <xsl:text>Note Description</xsl:text>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell border="solid black 1px"
                                       padding="2px">
                            <fo:block>
                                <xsl:value-of select="dn_description_last"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
                <xsl:if
                        test="string-length(dn_detailed_note_last)>0">
                    <fo:table-row>
                        <fo:table-cell border="solid black 1px"
                                       padding="2px">
                            <fo:block font-weight="bold">
                                <xsl:text>Detailed Notes</xsl:text>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell border="solid black 1px"
                                       padding="2px">
                            <fo:block>
                                <xsl:value-of select="dn_detailed_note_last"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
                <fo:table-row height="2cm">
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:text>Site Response</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px"
                                   padding="2px">
                        <fo:block/>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <!-- Lookup lists for matching object details by OID. -->
    <xsl:key name="site-name"
             match="odm:Study"
             use="@OID"/>
    <xsl:key name="subject-id"
             match="odm:SubjectData"
             use="@OID"/>

    <!-- Limit the scope of metadata keys to the first (the parent) study. -->
    <xsl:key name="event-name"
             match="odm:Study[position()=1]//odm:StudyEventDef"
             use="@OID"/>
    <xsl:key name="form-name"
             match="odm:Study[position()=1]//odm:FormDef"
             use="@OID"/>
    <xsl:key name="form-section"
             match="odm:Study[position()=1]//OpenClinica:ItemDetails"
             use="@ItemOID"/>
    <xsl:key name="itemgroup-name"
             match="odm:Study[position()=1]//odm:ItemGroupDef"
             use="@OID"/>
    <xsl:key name="item-name"
             match="odm:Study[position()=1]//odm:ItemDef"
             use="@OID"/>
    <xsl:key name="code-list"
             match="odm:Study[position()=1]//odm:CodeList"
             use="@OID"/>

    <!-- Template to suppress text output in data mode templates. -->
    <xsl:template match="text()"
                  mode="data"/>

    <!-- Template to return the study node. -->
    <xsl:template match="odm:ODM"
                  mode="data">
        <xsl:element name="study">
            <xsl:element name="study_name">
                <xsl:value-of select="odm:Study[position()=1]/
                    odm:GlobalVariables/odm:StudyName"/>
            </xsl:element>
            <xsl:apply-templates mode="data"
                                 select="*"/>
        </xsl:element>
    </xsl:template>

    <!-- Template to return the site nodes. -->
    <xsl:template match="odm:ClinicalData[descendant::
        OpenClinica:DiscrepancyNotes/OpenClinica:DiscrepancyNote
        [@Status='New' or @Status='Updated']]"
                  mode="data">
        <xsl:element name="site">
            <xsl:element name="site_name">
                <xsl:value-of select="substring-after(key('site-name', 
                @StudyOID)/odm:GlobalVariables/odm:StudyName,' - ')"/>
            </xsl:element>
            <xsl:apply-templates mode="data"/>
        </xsl:element>
    </xsl:template>

    <!-- Template to return the subject nodes. -->
    <xsl:template match="odm:SubjectData[descendant::
        OpenClinica:DiscrepancyNotes/OpenClinica:DiscrepancyNote
        [@Status='New' or @Status='Updated']]"
                  mode="data">
        <xsl:element name="subject">
            <xsl:element name="subject_id">
                <xsl:value-of select="@OpenClinica:StudySubjectID"/>
            </xsl:element>
            <xsl:apply-templates mode="data"/>
        </xsl:element>
    </xsl:template>

    <!-- Template to return the discrepancy note nodes.
         - Does a lookup of single choice list values to their value labels.
      -->
    <xsl:template match="OpenClinica:DiscrepancyNotes/
        OpenClinica:DiscrepancyNote[@Status='New' or @Status='Updated']"
                  mode="data">
        <xsl:element name="dnote">
            <xsl:element name="dn_id">
                <xsl:value-of select="@ID"/>
            </xsl:element>
            <xsl:element name="dn_status">
                <xsl:value-of select="@Status"/>
            </xsl:element>
            <xsl:element name="dn_description_last">
                <xsl:value-of select="OpenClinica:ChildNote[position
                ()=../@NumberOfChildNotes]/OpenClinica:Description"/>
            </xsl:element>
            <xsl:element name="dn_detailed_note_last">
                <xsl:value-of select="OpenClinica:ChildNote[last()]
                    /OpenClinica:DetailedNote"/>
            </xsl:element>
            <xsl:element name="dn_entity_id">
                <xsl:value-of select="../@EntityID"/>
            </xsl:element>
            <xsl:element name="dn_entity_type">
                <xsl:choose>
                    <xsl:when test="substring(../@EntityID,1,2)='I_'">
                        <xsl:text>Item</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring(../@EntityID,1,2)='F_'">
                        <xsl:text>Form</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring(../@EntityID,1,3)='SE_'">
                        <xsl:text>Event</xsl:text>
                    </xsl:when>
                    <xsl:when test="substring(../@EntityID,1,3)='SS_'">
                        <xsl:text>Subject</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:element>
            <xsl:element name="dn_entity_detail">
                <xsl:variable name="item-value"
                              select="ancestor::odm:ItemData/@Value"/>
                <xsl:element name="event_name">
                    <xsl:value-of select="key('event-name',ancestor::
                        odm:StudyEventData/@StudyEventOID)/@Name"/>
                </xsl:element>
                <xsl:element name="event_repeat">
                    <xsl:value-of select="ancestor::
                        odm:StudyEventData/@StudyEventRepeatKey"/>
                </xsl:element>
                <xsl:element name="form_name">
                    <xsl:value-of select="key('form-name',ancestor::
                        odm:FormData/@FormOID)/@Name"/>
                </xsl:element>
                <xsl:element name="form_section">
                    <xsl:variable name="form_oid"
                                  select="ancestor::
                        odm:FormData/@FormOID"/>
                    <xsl:value-of select="key('form-section',../@EntityID)
                        /OpenClinica:ItemPresentInForm[@FormOID=$form_oid]
                        /OpenClinica:SectionLabel"/>
                </xsl:element>
                <xsl:element name="itemgroup_name">
                    <xsl:value-of select="key('itemgroup-name',ancestor::
                        odm:ItemGroupData/@ItemGroupOID)/@Name"/>
                </xsl:element>
                <xsl:element name="itemgroup_repeat">
                    <xsl:value-of select="ancestor::
                        odm:ItemGroupData/@ItemGroupRepeatKey"/>
                </xsl:element>
                <xsl:element name="item_name">
                    <xsl:value-of select="key('item-name',../@EntityID)
                        /@Comment"/>
                </xsl:element>
                <xsl:element name="item_value">
                    <xsl:value-of select="$item-value"/>
                </xsl:element>
                <xsl:element name="item_code_list_label">
                    <xsl:value-of
                            select="key('code-list',key('item-name',../@EntityID)/odm:CodeListRef/@CodeListOID)/odm:CodeListItem[@CodedValue=$item-value]/odm:Decode/odm:TranslatedText/text()"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:apply-templates mode="data"/>
    </xsl:template>
</xsl:stylesheet>