<?xml version="1.0" ?>
<xsl:stylesheet 
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:odm="http://www.cdisc.org/ns/odm/v1.3"
    xmlns:OpenClinica="http://www.openclinica.org/ns/odm_ext_v130/v3.1"
    exclude-result-prefixes="odm OpenClinica">
    <xsl:output method="html" indent="yes" encoding="utf-8"/>
    <xsl:strip-space elements="*"/>

    <!-- template to suppress unnecessary Study and AdminData nodes -->
    <xsl:template match="text()"/>

    <xsl:template match="/">
        <html>
            <style>
                <xsl:text>
                    @media print {
                        .table_dnote + h3
                        {
                            page-break-before:always;
                        }

                        .table_dnote:nth-of-type(2n)
                        {
                            page-break-after:always;
                        }

                        .table_dnote tr
                        {
                            page-break-inside:avoid;
                        }
                    }

                    @media all {
                        body
                        {
                            font-family:Arial;
                        }

                        .table_dnote
                        {
                            margin-bottom:10px;
                        }

                        .table_dnote,
                        .table_entity_detail
                        {
                            border-collapse:collapse;
                            font-size:small;
                            width:100%;
                        }

                        .table_dnote,
                        .table_dnote th,
                        .table_dnote td
                        {
                            border:1px solid #000;
                            padding:5px;
                        }

                        .table_dnote td:nth-child(odd)
                        {
                            font-weight:bold;
                            width:10%;
                        }

                        .table_entity_detail td:nth-child(odd)
                        {
                            font-weight:bold;
                            width:25%;
                        }

                        .td_site_response
                        {
                            height:2cm;
                        }
                    }
                </xsl:text>
            </style>
            <meta charset="utf-8"/>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="site">
        <h3>
            <xsl:value-of select="../study_name"/>
            <xsl:text> Queries - </xsl:text>
            <xsl:value-of select="site_name"/>
        </h3>
        <xsl:apply-templates>
            <xsl:sort select="subject_id"/>
        </xsl:apply-templates>
    </xsl:template>
    <xsl:template match="dnote">
        <table class="table_dnote">
            <tr>
                <td>
                    <xsl:text>Subject</xsl:text>
                </td>
                <td>
                    <xsl:value-of select="../subject_id"/>
                </td>
            </tr>
            <tr>
                <td>
                    <xsl:text>Entity Type</xsl:text>
                </td>
                <td>
                    <xsl:value-of select="dn_entity_type"/>
                </td>
            </tr>
            <tr>
                <td>
                    <xsl:text>Entity Details</xsl:text>
                </td>
                <td>
                    <xsl:choose>
                        <xsl:when test="not(dn_entity_type='Subject')">
                            <table class="table_entity_detail">
                                <tr>
                                    <td>
                                        <xsl:text>Event Name</xsl:text>
                                    </td>
                                    <td>
                                        <xsl:value-of select="dn_entity_detail/event_name"/>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <xsl:text>Event Repeat</xsl:text>
                                    </td>
                                    <td>
                                        <xsl:value-of select="dn_entity_detail/event_repeat"/>
                                    </td>
                                </tr>
                                <xsl:choose>
                                    <xsl:when test="dn_entity_type='Item' or dn_entity_type='Form'">
                                        <tr>
                                            <td>
                                                <xsl:text>Form Name</xsl:text>
                                            </td>
                                            <td>
                                                <xsl:value-of select="dn_entity_detail/form_name"/>
                                            </td>
                                        </tr>
                                        <xsl:choose>
                                            <xsl:when test="dn_entity_type='Item'">
                                                <tr>
                                                    <td>
                                                        <xsl:text>Form Section</xsl:text>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="dn_entity_detail/form_section"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <xsl:text>ItemGroup Name</xsl:text>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="dn_entity_detail/itemgroup_name"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <xsl:text>ItemGroup Repeat</xsl:text>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="dn_entity_detail/itemgroup_repeat"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <xsl:text>Item Name</xsl:text>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="dn_entity_detail/item_name"/>
                                                    </td>
                                                </tr>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                </xsl:choose>
                            </table>
                        </xsl:when>
                        <xsl:when test="dn_entity_type='Subject'">
                            <xsl:value-of select="dn_entity_id"/>
                        </xsl:when>
                    </xsl:choose>
                </td>
            </tr>
            <tr>
                <td>
                    <xsl:text>Note Status</xsl:text>
                </td>
                <td>
                    <xsl:value-of select="dn_status"/>
                </td>
            </tr>
            <tr>
                <td>
                    <xsl:text>Note Description</xsl:text>
                </td>
                <td>
                    <xsl:if test="string-length(dn_description_last)>0">
                        <xsl:text>Description: </xsl:text>
                        <br/>
                        <xsl:value-of select="dn_description_last"/>
                        <br/>
                    </xsl:if>
                    <xsl:if test="string-length(dn_detailed_note_last)>0">
                        <xsl:text>Detailed Notes: </xsl:text>
                        <br/>
                        <xsl:value-of select="dn_detailed_note_last"/>
                    </xsl:if>
                </td>
            </tr>
            <tr>
                <td class="td_site_response">
                    <xsl:text>Site Response</xsl:text>
                </td>
                <td/>
            </tr>
        </table>
    </xsl:template>
</xsl:stylesheet>