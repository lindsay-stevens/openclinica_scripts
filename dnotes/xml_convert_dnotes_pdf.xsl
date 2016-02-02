<?xml version="1.0" ?>
<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
    xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1"
    exclude-result-prefixes="odm OpenClinica">

    <!-- suppress unnecessary Study and AdminData nodes -->
    <xsl:template match="text()"/>

    <!-- master layout -->
    <xsl:template match="/">
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
                <xsl:apply-templates mode="doc_bookmark"/>
            </fo:bookmark-tree>

            <fo:page-sequence master-reference="main">
                <fo:static-content 
                    flow-name="xsl-region-before"
                    font-size="14pt"
                    font-weight="bold">
                    <fo:block>
                        <xsl:value-of select="study/study_name"/>
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
                    <xsl:apply-templates mode="doc_content"/>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template> 

    <!-- site name bookmarks -->
    <xsl:template match="site" mode="doc_bookmark">
        <fo:bookmark starting-state="hide">
            <xsl:attribute name="internal-destination">
                <xsl:value-of select="site_name"/>
            </xsl:attribute>
            <fo:bookmark-title>
                <xsl:value-of select="site_name"/>
            </fo:bookmark-title>
            <xsl:apply-templates mode="doc_bookmark">
                <xsl:sort select="subject_id"/>
            </xsl:apply-templates>
        </fo:bookmark>
    </xsl:template>

    <!-- subject id bookmarks within sites -->
    <xsl:template match="subject" mode="doc_bookmark">
        <fo:bookmark starting-state="hide">
            <xsl:attribute name="internal-destination">
                <xsl:value-of select="subject_id"/>
            </xsl:attribute>
            <fo:bookmark-title>
                <xsl:value-of select="subject_id"/>
            </fo:bookmark-title>
            <xsl:apply-templates mode="doc_bookmark" select="dnote">
                <xsl:sort select="concat(substring('000000000',1,
                    12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
            </xsl:apply-templates>
        </fo:bookmark>
    </xsl:template>

    <!-- note id bookmarks within subjects -->
    <xsl:template match="dnote" mode="doc_bookmark">
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

    <xsl:template match="site" mode="doc_content">
        <fo:block page-break-after="always">
            <xsl:attribute name="id">
                <xsl:value-of select="site_name"/>
            </xsl:attribute>
            <fo:marker marker-class-name="mark-site-name">
                <xsl:value-of select="site_name"/>
            </fo:marker>
            <xsl:apply-templates mode="doc_content" select="subject">
                <xsl:sort select="subject_id"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>

    <!-- subject content blocks -->
    <xsl:template match="subject" mode="doc_content">
        <fo:block page-break-after="always">
            <xsl:attribute name="id">
                <xsl:value-of select="subject_id"/>
            </xsl:attribute>
            <fo:marker marker-class-name="mark-subject-id">
                <xsl:value-of select="subject_id"/>
            </fo:marker>
            <xsl:apply-templates mode="doc_content" select="dnote">
                <xsl:sort select="concat(substring('000000000',1,12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>

    <!-- note content blocks within subjects-->
    <xsl:template match="dnote" mode="doc_content">
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
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:attribute name="id">
                                <xsl:value-of select="concat(substring('000000000',1,12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
                            </xsl:attribute>
                            <xsl:text>Note ID</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block>
                            <xsl:value-of select="concat(substring('000000000',1,12-string-length(dn_id)),substring-after(dn_id,'DN_'))"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <fo:table-row>
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:text>Entity Type</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block>
                            <xsl:value-of select="dn_entity_type"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:choose>
                    <xsl:when test="dn_entity_type='Item' or dn_entity_type='Event'">
                        <fo:table-row>
                            <fo:table-cell border="solid black 1px" padding="2px">
                                <fo:block font-weight="bold">
                                    <xsl:text>Event Name</xsl:text>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell border="solid black 1px" padding="2px">
                                <fo:block>
                                    <xsl:value-of select="dn_entity_detail/event_name"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                        <fo:table-row>
                            <fo:table-cell border="solid black 1px" padding="2px">
                                <fo:block font-weight="bold">
                                    <xsl:text>Event Repeat</xsl:text>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell border="solid black 1px" padding="2px">
                                <fo:block>
                                    <xsl:value-of select="dn_entity_detail/event_repeat"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                        <xsl:choose>
                            <xsl:when test="dn_entity_type='Item'">
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Form Name</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block>
                                            <xsl:value-of select="dn_entity_detail/form_name"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Form Section</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block>
                                            <xsl:value-of select="dn_entity_detail/form_section"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>ItemGroup Name</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block>
                                            <xsl:value-of select="dn_entity_detail/itemgroup_name"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>ItemGroup Repeat</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block>
                                            <xsl:value-of select="dn_entity_detail/itemgroup_repeat"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Item Name</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block>
                                            <xsl:value-of select="dn_entity_detail/item_name"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Item Value</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block>
                                            <xsl:value-of select="dn_entity_detail/item_value"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                                <fo:table-row>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block font-weight="bold">
                                            <xsl:text>Item Code List Label</xsl:text>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border="solid black 1px" padding="2px">
                                        <fo:block>
                                            <xsl:value-of select="dn_entity_detail/item_code_list_label"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="dn_entity_type='Subject'">
                        <fo:table-row>
                            <fo:table-cell border="solid black 1px" padding="2px">
                                <fo:block font-weight="bold">
                                    <xsl:text>Entity ID</xsl:text>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell border="solid black 1px" padding="2px">
                                <fo:block>
                                    <xsl:value-of select="dn_entity_id"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </xsl:when>
                </xsl:choose>
                <fo:table-row>
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:text>Note Status</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block>
                            <xsl:value-of select="dn_status"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
                <xsl:if test="string-length(dn_description_last)>0">
                    <fo:table-row>
                        <fo:table-cell border="solid black 1px" padding="2px">
                            <fo:block font-weight="bold">
                                <xsl:text>Note Description</xsl:text>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell border="solid black 1px" padding="2px">
                            <fo:block>
                                <xsl:value-of select="dn_description_last"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
                <xsl:if test="string-length(dn_detailed_note_last)>0">
                    <fo:table-row>
                        <fo:table-cell border="solid black 1px" padding="2px">
                            <fo:block font-weight="bold">
                                <xsl:text>Detailed Notes</xsl:text>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell border="solid black 1px" padding="2px">
                            <fo:block>
                                <xsl:value-of select="dn_detailed_note_last"/>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </xsl:if>
                <fo:table-row height="2cm">
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block font-weight="bold">
                            <xsl:text>Site Response</xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border="solid black 1px" padding="2px">
                        <fo:block/>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>
</xsl:stylesheet>