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
                xmlns:mrc="http://standards.iso.org/iso/19115/-3/mrc/2.0"
                xmlns:mrd="http://standards.iso.org/iso/19115/-3/mrd/1.0"
                xmlns:mri="http://standards.iso.org/iso/19115/-3/mri/1.0"
                xmlns:mrs="http://standards.iso.org/iso/19115/-3/mrs/1.0"
                xmlns:msr="http://standards.iso.org/iso/19115/-3/msr/2.0"
                xmlns:mai="http://standards.iso.org/iso/19115/-3/mai/1.0"
                xmlns:mdq="http://standards.iso.org/iso/19157/-2/mdq/1.0"
                xmlns:gco="http://standards.iso.org/iso/19115/-3/gco/1.0"
                xmlns:gml="http://www.opengis.net/gml/3.2"
                xmlns:mcp="http://schemas.aodn.org.au/mcp-2.0"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                exclude-result-prefixes="#all">

  <xsl:template match="mcp:dataParameters" mode="from19139to19115-3">
    <mdb:contentInfo>
      <mrc:MD_CoverageDescription>
        <mrc:attributeDescription gco:nilReason="inapplicable"/>
        <mrc:attributeGroup> 
          <mrc:MD_AttributeGroup>
            <mrc:contentType>
              <mrc:MD_CoverageContentTypeCode codeList='http://standards.iso.org/iso/19115/resources/Codelist/cat/codelists.xml#MD_CoverageContentTypeCode' codeListValue='physicalMeasurement'/>
            </mrc:contentType>
            <xsl:for-each select="*/mcp:dataParameter/mcp:DP_DataParameter">
              <mrc:attribute>
                <mrc:MD_SampleDimension>
                  <xsl:for-each select="mcp:parameterName/mcp:DP_Term">
                    <mrc:name>
                      <xsl:apply-templates mode="mcpdp" select="."/>
                    </mrc:name>
                  </xsl:for-each>
                  <!-- FIXME: mrc:units is 0..1 so this will generate an invalid metadata record! -->
                  <xsl:for-each select="mcp:parameterUnits/mcp:DP_Term">
                    <mrc:units>
                      <gml:BaseUnit gml:id="{generate-id()}">
                        <gml:identifier>
                          <xsl:if test="mcp:vocabularyRelationship/mcp:DP_VocabularyRelationship/mcp:vocabularyTermURL/gmd:URL">
                            <xsl:attribute name="codeSpace">
                              <xsl:value-of select="mcp:vocabularyRelationship/mcp:DP_VocabularyRelationship/mcp:vocabularyTermURL/gmd:URL"/>
                            </xsl:attribute>
                            <xsl:value-of select="mcp:vocabularyRelationship/mcp:DP_VocabularyRelationship/mcp:vocabularyTermURL/gmd:URL"/>
                          </xsl:if>
                        </gml:identifier>
                        <gml:name>
                          <xsl:value-of select="mcp:term/gcoold:CharacterString"/>
                        </gml:name>
                        <gml:unitsSystem/>
                      </gml:BaseUnit>
                    </mrc:units>
                  </xsl:for-each>
                  <xsl:if test="string(number(mcp:parameterMaximumValue/*)) != 'NaN'">
                    <mrc:maxValue>
                      <gco:Real><xsl:value-of select="mcp:parameterMaximumValue/*"/></gco:Real>
                    </mrc:maxValue> 
                  </xsl:if>
                  <xsl:if test="string(number(mcp:parameterMinimumValue/*)) != 'NaN'">
                    <mrc:minValue>
                      <gco:Real><xsl:value-of select="mcp:parameterMinimumValue/*"/></gco:Real>
                    </mrc:minValue> 
                  </xsl:if>
                  <xsl:if test="mcp:platform or mcp:parameterDeterminationInstrument">
                    <mrc:otherProperty>
                      <gco:Record xsi:type="mac:MI_AcquisitionInformation_PropertyType">
                        <mac:MI_AcquisitionInformation>
                          <mac:scope>
                            <mcc:MD_Scope>
                              <mcc:level>
                                <mcc:MD_ScopeCode codeList="codeListLocation#MD_ScopeCode" codeListValue="collectionHardware"/>
                              </mcc:level>
                            </mcc:MD_Scope>
                          </mac:scope>
                          <mac:platform>
                            <mac:MI_Platform>
                              <mac:identifier>
                                <xsl:apply-templates mode="mcpdp" select="mcp:platform/mcp:DP_Term"/>
                              </mac:identifier>
                              <mac:description>
                                <gco:CharacterString>Platform used to capture data</gco:CharacterString>
                              </mac:description>
                              <xsl:choose>
                                <xsl:when test="mcp:parameterDeterminationInstrument">
                                  <mac:instrument>
                                    <mac:MI_Instrument>
                                      <mac:identifier>
                                        <xsl:apply-templates mode="mcpdp" select="mcp:parameterDeterminationInstrument/mcp:DP_Term"/>
                                      </mac:identifier>
                                      <mac:type gco:nilReason="notApplicable"/>
                                    </mac:MI_Instrument>
                                  </mac:instrument>
                                </xsl:when>
                                <xsl:otherwise>
                                  <mac:instrument gco:nilReason="unknown"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </mac:MI_Platform>
                          </mac:platform>
                        </mac:MI_AcquisitionInformation>
                      </gco:Record>
                    </mrc:otherProperty>
                   </xsl:if>
                </mrc:MD_SampleDimension>
              </mrc:attribute>
            </xsl:for-each>
          </mrc:MD_AttributeGroup>
        </mrc:attributeGroup> 
      </mrc:MD_CoverageDescription>
    </mdb:contentInfo>
  </xsl:template>

  <xsl:template mode="mcpdp" match="mcp:DP_Term">
    <mcc:MD_Identifier>
      <mcc:code>
        <xsl:choose>
          <xsl:when test="mcp:vocabularyRelationship/mcp:DP_VocabularyRelationship/mcp:vocabularyTermURL/gmd:URL">
            <gcx:Anchor xlink:href="{mcp:vocabularyRelationship/mcp:DP_VocabularyRelationship/mcp:vocabularyTermURL/gmd:URL}"><xsl:value-of select="mcp:term/gcoold:CharacterString"/></gcx:Anchor>
          </xsl:when>
          <xsl:otherwise>
            <gco:CharacterString><xsl:value-of select="mcp:term/gcoold:CharacterString"/></gco:CharacterString>
          </xsl:otherwise>
        </xsl:choose>
      </mcc:code>
      <xsl:if test="mcp:localDefinition/gcoold:CharacterString">
        <mcc:description>
          <gco:CharacterString><xsl:value-of select="mcp:localDefinition/gcoold:CharacterString"/></gco:CharacterString>
        </mcc:description>
      </xsl:if>
    </mcc:MD_Identifier>
  </xsl:template>

</xsl:stylesheet>
