<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gcoold="http://www.isotc211.org/2005/gco"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gsr="http://www.isotc211.org/2005/gsr"
                xmlns:gss="http://www.isotc211.org/2005/gss"
                xmlns:gts="http://www.isotc211.org/2005/gts"
                xmlns:srvold="http://www.isotc211.org/2005/srv"
                xmlns:gml30="http://www.opengis.net/gml"
                xmlns:cat="http://standards.iso.org/iso/19115/-3/cat/1.0"
                xmlns:cit="http://standards.iso.org/iso/19115/-3/cit/2.0"
                xmlns:gcx="http://standards.iso.org/iso/19115/-3/gcx/1.0"
                xmlns:gex="http://standards.iso.org/iso/19115/-3/gex/1.0"
                xmlns:lan="http://standards.iso.org/iso/19115/-3/lan/1.0"
                xmlns:srv="http://standards.iso.org/iso/19115/-3/srv/2.0"
                xmlns:mac="http://standards.iso.org/iso/19115/-3/mac/2.0"
                xmlns:mas="http://standards.iso.org/iso/19115/-3/mas/1.0"
                xmlns:mcc="http://standards.iso.org/iso/19115/-3/mcc/1.0"
                xmlns:mco="http://standards.iso.org/iso/19115/-3/mco/1.0"
                xmlns:mda="http://standards.iso.org/iso/19115/-3/mda/1.0"
                xmlns:mdb="http://standards.iso.org/iso/19115/-3/mdb/2.0"
                xmlns:mdt="http://standards.iso.org/iso/19115/-3/mdt/1.0"
                xmlns:mex="http://standards.iso.org/iso/19115/-3/mex/1.0"
                xmlns:mic="http://standards.iso.org/iso/19115/-3/mic/1.0"
                xmlns:mil="http://standards.iso.org/iso/19115/-3/mil/1.0"
                xmlns:mrl="http://standards.iso.org/iso/19115/-3/mrl/2.0"
                xmlns:mds="http://standards.iso.org/iso/19115/-3/mds/1.0"
                xmlns:mmi="http://standards.iso.org/iso/19115/-3/mmi/1.0"
                xmlns:mpc="http://standards.iso.org/iso/19115/-3/mpc/1.0"
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/1.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0"
                xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:mcpold="http://schemas.aodn.org.au/mcp-2.0"
                xmlns:mcp="http://schemas.aodn.org.au/mcp-3.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="#all">

  <xsl:template match="mcpold:dataParameters" mode="from19139to19115-3">
    <mdb:contentInfo>
      <mrc:MD_CoverageDescription>
        <mrc:attributeDescription gco:nilReason="inapplicable"/>
        <mrc:attributeGroup> 
          <mrc:MD_AttributeGroup>
            <mrc:contentType>
              <mrc:MD_CoverageContentTypeCode codeList='http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#MD_CoverageContentTypeCode' codeListValue='physicalMeasurement'/>
              <mrc:attribute>
                <mrc:MD_SampleDimension>
                  <mrc:otherProperty>
                    <gco:Record xsi:type="mcp:MD_DataParameters_PropertyType">
                      <xsl:apply-templates select="*/mcpold:dataParameter" mode="mcpdp"/>
                    </gco:Record>
                  </mrc:otherProperty>
                </mrc:MD_SampleDimension>
              </mrc:attribute>
            </mrc:contentType>
          </mrc:MD_AttributeGroup>
        </mrc:attributeGroup> 
      </mrc:MD_CoverageDescription>
    </mdb:contentInfo>
  </xsl:template>

  <xsl:template match="mcpold:*" mode="mcpdp">
    <xsl:variable name="localname" select="local-name()"/>
    <xsl:element name="{concat('mcp:',$localname)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*" mode="mcpdp"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="gmd:URL" mode="mcpdp">
    <xsl:element name="gco:CharacterString">
      <xsl:copy-of select="@*|text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="gcoold:*" mode="mcpdp">
    <xsl:variable name="localname" select="local-name()"/>
    <xsl:element name="{concat('gco:',$localname)}">
      <xsl:copy-of select="@*|text()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="*" mode="mcpdp">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="*" mode="mcpdp"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
