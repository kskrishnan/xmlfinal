<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.w3.org/1999/xhtml">
    <xsl:import href="common_mo.xsl"/>
    <xsl:param name="absolutebaseurl"/>
    <xsl:param name="relativepath"/>
    <xsl:param name="page_linked" select="'All'"/>

    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes"
        doctype-public="http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd"
        doctype-system="-//W3C//DTD XHTML Basic 1.1//EN"/>
    <xsl:variable name="title" select="'Department Listing'"/>
    <xsl:key name="dept_course" match="department" use="@code"/>
    <xsl:key name="course_grp" match="course" use="course_group/@code"/>
    <xsl:key name="course_dept" match="course" use="department/@code"/>

    <xsl:template match="/fas_courses">
        <h1>Harvard University FAS Departments</h1>
        <a href="http://localhost:8080/cocoon/final_project/home.html">
            [Return to Home]
        </a>
        <div id="wrap">
            
            <xsl:call-template name="page_nav"/>
        </div>
        <xsl:call-template name="list_departments"/>
    </xsl:template>

    <!--to list down all the courses under a department and course group if any exists-->
    <xsl:template name="list_departments">
        <ul>
            <xsl:for-each
                select="/fas_courses/course/department[generate-id()=generate-id(key('dept_course',@code)[1])]">
                <xsl:sort select="/dept_short_name"/>
                <xsl:variable name="var_dept" select="@code"/>
                <xsl:choose>
                    <!--                 to display everything under departments-->
                    <xsl:when test="$page_linked='All' or $page_linked = 'x'">
                        <xsl:if
                            test="count(distinct-values(//course[department/@code=$var_dept][@offered='Y'][course_level/@code='P']/course_group)) = 1">
                            <xsl:call-template name="dept_courses_count">
                                <xsl:with-param name="cur_dept" select="$var_dept"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if
                            test="count(distinct-values(//course[department/@code=$var_dept][@offered='Y'][course_level/@code='P']/course_group)) > 1">
                            <li>
                                <xsl:value-of select="./dept_short_name"/>
                                <ul>
                                    <xsl:call-template name="list_course_grps">
                                        <xsl:with-param name="cur_dept" select="$var_dept"/>
                                    </xsl:call-template>
                                </ul>
                            </li>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--                        to display the content of a selected page -->
                        <xsl:if
                            test="(position() gt (number($page_linked)-1) * 10) and (position() le number($page_linked) * 10)">
                            <xsl:if
                                test="count(distinct-values(//course[department/@code=$var_dept][@offered='Y'][course_level/@code='P']/course_group)) = 1">
                                <xsl:call-template name="dept_courses_count">
                                    <xsl:with-param name="cur_dept" select="$var_dept"/>
                                </xsl:call-template>
                            </xsl:if>
                            <xsl:if
                                test="count(distinct-values(//course[department/@code=$var_dept][@offered='Y'][course_level/@code='P']/course_group)) > 1">
                                <li>
                                    <xsl:value-of select="./dept_short_name"/>
                                    <ul>
                                        <xsl:call-template name="list_course_grps">
                                            <xsl:with-param name="cur_dept" select="$var_dept"/>
                                        </xsl:call-template>
                                    </ul>
                                </li>
                            </xsl:if>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </ul>
    </xsl:template>

    <!--to list courses under course groups-->
    <xsl:template name="list_course_grps">
        <xsl:param name="cur_dept"/>
        <xsl:for-each
            select="/fas_courses/course[department/@code=$cur_dept][generate-id()=generate-id(key('course_grp',course_group/@code)[department/@code=$cur_dept][1])]">
            <xsl:sort select="./course_group"/>
            <xsl:if
                test="count(key('course_grp',./course_group/@code)[department/@code=$cur_dept][@offered='Y'][course_level/@code='P']) > 0">
                <li>
                    <a href="course_groups/{course_group/@code}page1.xhtml">
                        <xsl:value-of select="./course_group"/>
                    </a>
                    <xsl:value-of
                        select="concat(' (',count(key('course_grp',course_group/@code)[department/@code=$cur_dept][@offered='Y'][course_level/@code='P']),')')"
                    />
                </li>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!--to get the courses count-->
    <xsl:template name="dept_courses_count">
        <xsl:param name="cur_dept"/>
        <xsl:for-each
            select="/fas_courses/course[department/@code=$cur_dept][generate-id()=generate-id(key('course_grp',course_group/@code)[department/@code=$cur_dept][1])]">
            <xsl:sort select="./course_group"/>

            <xsl:if
                test="count(key('course_grp',./course_group/@code)[department/@code=$cur_dept][@offered='Y'][course_level/@code='P']) > 0">
                <li>
                    <a href="course_groups/{course_group/@code}page1.xhtml">
                        <xsl:value-of select="./department/dept_short_name"/>
                    </a>
                    <xsl:value-of
                        select="concat(' (',count(key('course_grp',course_group/@code)[department/@code=$cur_dept][@offered='Y'][course_level/@code='P']),')')"
                    />
                </li>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- page navigation to control display content-->
    <xsl:template name="page_nav">
        <xsl:variable name="dept_cnt"
            select="count(distinct-values(key('dept_course',course/department/@code)))"/>
        <xsl:if test="$dept_cnt gt 10">
            <div>
                <xsl:text>Pages: </xsl:text>
                <a href="{relativepath}pagex.xhtml">
                    <xsl:if test="$page_linked = 'All' or $page_linked = 'x'">
                        <xsl:attribute name="id">sectcurrent</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="'All'"/>
                </a> | <xsl:for-each-group select="course" group-by="department/@code">
                    <xsl:sort select="
                department/dept_short_name"/>
                    <xsl:if test="position() mod 10 = 1">
                        <xsl:variable name="page_no" select="((position() - 1) div 10)+1"/>
                        <a href="{relativepath}page{$page_no}.xhtml">
                            <xsl:if test="number($page_linked) = number($page_no)">
                                <xsl:attribute name="id">sectcurrent</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$page_no"/>
                        </a>
                        <xsl:if test="$page_no*10 lt $dept_cnt"> | </xsl:if>
                    </xsl:if>
                </xsl:for-each-group>
            </div>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>