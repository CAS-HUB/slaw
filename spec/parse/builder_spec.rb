# encoding: UTF-8

require 'spec_helper'
require 'slaw'

describe Slaw::Parse::Builder do
  let(:parser) { double("parser") }
  subject { Slaw::Parse::Builder.new(parser: parser) }

  describe '#adjust_blocklists' do
    it 'should nest simple blocks' do
      doc = xml2doc(subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.a">
                <num>(a)</num>
                <p>foo</p>
              </item>
              <item id="section-10.1.lst0.i">
                <num>(i)</num>
                <p>item-i</p>
              </item>
              <item id="section-10.1.lst0.ii">
                <num>(ii)</num>
                <p>item-ii</p>
              </item>
              <item id="section-10.1.lst0.iii">
                <num>(iii)</num>
                <p>item-iii</p>
              </item>
              <item id="section-10.1.lst0.aa">
                <num>(aa)</num>
                <p>item-aa</p>
              </item>
              <item id="section-10.1.lst0.bb">
                <num>(bb)</num>
                <p>item-bb</p>
              </item>
            </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.a">
                <num>(a)</num>
                <blockList id="section-10.1.lst0.a.list0">
                  <listIntroduction>foo</listIntroduction>
                  <item id="section-10.1.lst0.a.list0.i">
                    <num>(i)</num>
                    <p>item-i</p>
                  </item>
                  <item id="section-10.1.lst0.a.list0.ii">
                    <num>(ii)</num>
                    <p>item-ii</p>
                  </item>
                  <item id="section-10.1.lst0.a.list0.iii">
                    <num>(iii)</num>
                    <blockList id="section-10.1.lst0.a.list0.iii.list0">
                      <listIntroduction>item-iii</listIntroduction>
                      <item id="section-10.1.lst0.a.list0.iii.list0.aa">
                        <num>(aa)</num>
                        <p>item-aa</p>
                      </item>
                      <item id="section-10.1.lst0.a.list0.iii.list0.bb">
                        <num>(bb)</num>
                        <p>item-bb</p>
                      </item>
                    </blockList>
                  </item>
                </blockList>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------

    it 'should jump back up a level' do
      doc = xml2doc(subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.a">
                <num>(a)</num>
                <p>foo</p>
              </item>
              <item id="section-10.1.lst0.i">
                <num>(i)</num>
                <p>item-i</p>
              </item>
              <item id="section-10.1.lst0.ii">
                <num>(ii)</num>
                <p>item-ii</p>
              </item>
              <item id="section-10.1.lst0.c">
                <num>(c)</num>
                <p>item-c</p>
              </item>
            </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.a">
                <num>(a)</num>
                <blockList id="section-10.1.lst0.a.list0">
                  <listIntroduction>foo</listIntroduction>
                  <item id="section-10.1.lst0.a.list0.i">
                    <num>(i)</num>
                    <p>item-i</p>
                  </item>
                  <item id="section-10.1.lst0.a.list0.ii">
                    <num>(ii)</num>
                    <p>item-ii</p>
                  </item>
                </blockList>
              </item>
              <item id="section-10.1.lst0.c">
                <num>(c)</num>
                <p>item-c</p>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------

    it 'should handle (i) correctly' do
      doc = xml2doc(subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.h">
                <num>(h)</num>
                <p>foo</p>
              </item>
              <item id="section-10.1.lst0.i">
                <num>(i)</num>
                <p>item-i</p>
              </item>
              <item id="section-10.1.lst0.j">
                <num>(j)</num>
                <p>item-ii</p>
              </item>
            </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.h">
                <num>(h)</num>
                <p>foo</p>
              </item>
              <item id="section-10.1.lst0.i">
                <num>(i)</num>
                <p>item-i</p>
              </item>
              <item id="section-10.1.lst0.j">
                <num>(j)</num>
                <p>item-ii</p>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------

    it 'should handle (u) (v) and (x) correctly' do
      doc = xml2doc(subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.t">
                <num>(t)</num>
                <p>foo</p>
              </item>
              <item id="section-10.1.lst0.u">
                <num>(u)</num>
                <p>item-i</p>
              </item>
              <item id="section-10.1.lst0.v">
                <num>(v)</num>
                <p>item-ii</p>
              </item>
              <item id="section-10.1.lst0.w">
                <num>(w)</num>
                <p>item-ii</p>
              </item>
              <item id="section-10.1.lst0.x">
                <num>(x)</num>
                <p>item-ii</p>
              </item>
            </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.t">
                <num>(t)</num>
                <p>foo</p>
              </item>
              <item id="section-10.1.lst0.u">
                <num>(u)</num>
                <p>item-i</p>
              </item>
              <item id="section-10.1.lst0.v">
                <num>(v)</num>
                <p>item-ii</p>
              </item>
              <item id="section-10.1.lst0.w">
                <num>(w)</num>
                <p>item-ii</p>
              </item>
              <item id="section-10.1.lst0.x">
                <num>(x)</num>
                <p>item-ii</p>
              </item>
            </blockList>
XML
      )
    end


    # -------------------------------------------------------------------------

    it 'should handle (j) correctly' do
      doc = xml2doc(subsection(<<XML
              <blockList id="section-28.3.list2">
                <item id="section-28.3.list2.g">
                  <num>(g)</num>
                  <p>all <term refersTo="#term-memorial_work" id="trm381">memorial work</term> up to 150 mm in thickness must be securely attached to the base;</p>
                </item>
                <item id="section-28.3.list2.h">
                  <num>(h)</num>
                  <p>all the components of <term refersTo="#term-memorial_work" id="trm382">memorial work</term> must be completed before being brought into a <term refersTo="#term-cemetery" id="trm383">cemetery</term>;</p>
                </item>
                <item id="section-28.3.list2.i">
                  <num>(i)</num>
                  <p>footstones must consist of one solid piece;</p>
                </item>
                <item id="section-28.3.list2.j">
                  <num>(j)</num>
                  <p>in all cases where <term refersTo="#term-memorial_work" id="trm384">memorial work</term> rests on a base -</p>
                </item>
                <item id="section-28.3.list2.i">
                  <num>(i)</num>
                  <p>such <term refersTo="#term-memorial_work" id="trm385">memorial work</term> must have a foundation;</p>
                </item>
                <item id="section-28.3.list2.ii">
                  <num>(ii)</num>
                  <p>such <term refersTo="#term-memorial_work" id="trm386">memorial work</term> must be set with cement mortar;</p>
                </item>
                <item id="section-28.3.list2.iii">
                  <num>(iii)</num>
                  <p>the bottom base of a single <term refersTo="#term-memorial_work" id="trm387">memorial work</term> must not be less than 900mm long 220 mm wide x 250 mm thick and that of a double <term refersTo="#term-memorial_work" id="trm388">memorial work</term> not less than 2 286 mm long x 200 mm wide x 250 mm thick; and</p>
                </item>
              </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-28.3.list2">
              <item id="section-28.3.list2.g">
                <num>(g)</num>
                <p>all <term refersTo="#term-memorial_work" id="trm381">memorial work</term> up to 150 mm in thickness must be securely attached to the base;</p>
              </item>
              <item id="section-28.3.list2.h">
                <num>(h)</num>
                <p>all the components of <term refersTo="#term-memorial_work" id="trm382">memorial work</term> must be completed before being brought into a <term refersTo="#term-cemetery" id="trm383">cemetery</term>;</p>
              </item>
              <item id="section-28.3.list2.i">
                <num>(i)</num>
                <p>footstones must consist of one solid piece;</p>
              </item>
              <item id="section-28.3.list2.j">
                <num>(j)</num>
                <blockList id="section-28.3.list2.j.list0">
                  <listIntroduction>in all cases where <term refersTo="#term-memorial_work" id="trm384">memorial work</term> rests on a base -</listIntroduction>
                  <item id="section-28.3.list2.j.list0.i">
                    <num>(i)</num>
                    <p>such <term refersTo="#term-memorial_work" id="trm385">memorial work</term> must have a foundation;</p>
                  </item>
                  <item id="section-28.3.list2.j.list0.ii">
                    <num>(ii)</num>
                    <p>such <term refersTo="#term-memorial_work" id="trm386">memorial work</term> must be set with cement mortar;</p>
                  </item>
                  <item id="section-28.3.list2.j.list0.iii">
                    <num>(iii)</num>
                    <p>the bottom base of a single <term refersTo="#term-memorial_work" id="trm387">memorial work</term> must not be less than 900mm long 220 mm wide x 250 mm thick and that of a double <term refersTo="#term-memorial_work" id="trm388">memorial work</term> not less than 2 286 mm long x 200 mm wide x 250 mm thick; and</p>
                  </item>
                </blockList>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------
    it 'should handle (I) correctly' do
      doc = xml2doc(subsection(<<XML
              <blockList id="section-28.3.list2">
                <item id="section-28.3.list2.g">
                  <num>(g)</num>
                  <p>all memorial work up to 150 mm in thickness must be securely attached to the base;</p>
                </item>
                <item id="section-28.3.list2.h">
                  <num>(h)</num>
                  <p>all the components of memorial work must be completed before being brought into a cemetery;</p>
                </item>
                <item id="section-28.3.list2.i">
                  <num>(i)</num>
                  <p>item i</p>
                </item>
                <item id="section-28.3.list2.I">
                  <num>(I)</num>
                  <p>a subitem</p>
                </item>
                <item id="section-28.3.list2.II">
                  <num>(II)</num>
                  <p>another subitem</p>
                </item>
                <item id="section-28.3.list2.j">
                  <num>(j)</num>
                  <p>in all cases where memorial work rests on a base -</p>
                </item>
                <item id="section-28.3.list2.i">
                  <num>(i)</num>
                  <p>such memorial work must have a foundation;</p>
                </item>
                <item id="section-28.3.list2.ii">
                  <num>(ii)</num>
                  <p>such memorial work must be set with cement mortar;</p>
                </item>
                <item id="section-28.3.list2.iii">
                  <num>(iii)</num>
                  <p>the bottom base of a single memorial work must not be less than 900mm long 220 mm wide x 250 mm thick and that of a double memorial work not less than 2 286 mm long x 200 mm wide x 250 mm thick; and</p>
                </item>
              </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-28.3.list2">
              <item id="section-28.3.list2.g">
                <num>(g)</num>
                <p>all memorial work up to 150 mm in thickness must be securely attached to the base;</p>
              </item>
              <item id="section-28.3.list2.h">
                <num>(h)</num>
                <p>all the components of memorial work must be completed before being brought into a cemetery;</p>
              </item>
              <item id="section-28.3.list2.i">
                <num>(i)</num>
                <blockList id="section-28.3.list2.i.list0">
                  <listIntroduction>item i</listIntroduction>
                  <item id="section-28.3.list2.i.list0.I">
                    <num>(I)</num>
                    <p>a subitem</p>
                  </item>
                  <item id="section-28.3.list2.i.list0.II">
                    <num>(II)</num>
                    <p>another subitem</p>
                  </item>
                </blockList>
              </item>
              <item id="section-28.3.list2.j">
                <num>(j)</num>
                <blockList id="section-28.3.list2.j.list1">
                  <listIntroduction>in all cases where memorial work rests on a base -</listIntroduction>
                  <item id="section-28.3.list2.j.list1.i">
                    <num>(i)</num>
                    <p>such memorial work must have a foundation;</p>
                  </item>
                  <item id="section-28.3.list2.j.list1.ii">
                    <num>(ii)</num>
                    <p>such memorial work must be set with cement mortar;</p>
                  </item>
                  <item id="section-28.3.list2.j.list1.iii">
                    <num>(iii)</num>
                    <p>the bottom base of a single memorial work must not be less than 900mm long 220 mm wide x 250 mm thick and that of a double memorial work not less than 2 286 mm long x 200 mm wide x 250 mm thick; and</p>
                  </item>
                </blockList>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------

    it 'should treat (aa) after (z) as siblings' do
      doc = xml2doc(subsection(<<XML
        <blockList id="list0">
          <item id="list0.y">
            <num>(y)</num>
            <p>foo</p>
          </item>
          <item id="list0.z">
            <num>(z)</num>
            <p>item-z</p>
          </item>
          <item id="list0.aa">
            <num>(aa)</num>
            <p>item-aa</p>
          </item>
          <item id="list0.bb">
            <num>(bb)</num>
            <p>item-bb</p>
          </item>
        </blockList>
XML
    ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="list0">
              <item id="list0.y">
                <num>(y)</num>
                <p>foo</p>
              </item>
              <item id="list0.z">
                <num>(z)</num>
                <p>item-z</p>
              </item>
              <item id="list0.aa">
                <num>(aa)</num>
                <p>item-aa</p>
              </item>
              <item id="list0.bb">
                <num>(bb)</num>
                <p>item-bb</p>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------

    it 'should treat (AA) after (z) a sublist' do
      doc = xml2doc(subsection(<<XML
        <blockList id="list0">
          <item id="list0.y">
            <num>(y)</num>
            <p>foo</p>
          </item>
          <item id="list0.z">
            <num>(z)</num>
            <p>item-z</p>
          </item>
          <item id="list0.AA">
            <num>(AA)</num>
            <p>item-AA</p>
          </item>
          <item id="list0.BB">
            <num>(BB)</num>
            <p>item-BB</p>
          </item>
        </blockList>
XML
    ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="list0">
              <item id="list0.y">
                <num>(y)</num>
                <p>foo</p>
              </item>
              <item id="list0.z">
                <num>(z)</num>
                <blockList id="list0.z.list0">
                  <listIntroduction>item-z</listIntroduction>
                  <item id="list0.z.list0.AA">
                    <num>(AA)</num>
                    <p>item-AA</p>
                  </item>
                  <item id="list0.z.list0.BB">
                    <num>(BB)</num>
                    <p>item-BB</p>
                  </item>
                </blockList>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------

    it 'should handle deeply nested lists' do
      doc = xml2doc(subsection(<<XML
        <blockList id="list0">
          <item id="list0.a">
            <num>(a)</num>
            <p>foo</p>
          </item>
          <item id="list0.b">
            <num>(b)</num>
            <p>item-b</p>
          </item>
          <item id="list0.i">
            <num>(i)</num>
            <p>item-b-i</p>
          </item>
          <item id="list0.aa">
            <num>(aa)</num>
            <p>item-i-aa</p>
          </item>
          <item id="list0.bb">
            <num>(bb)</num>
            <p>item-i-bb</p>
          </item>
          <item id="list0.ii">
            <num>(ii)</num>
            <p>item-b-ii</p>
          </item>
          <item id="list0.c">
            <num>(c)</num>
            <p>item-c</p>
          </item>
          <item id="list0.i">
            <num>(i)</num>
            <p>item-c-i</p>
          </item>
          <item id="list0.ii">
            <num>(ii)</num>
            <p>item-c-ii</p>
          </item>
          <item id="list0.iii">
            <num>(iii)</num>
            <p>item-c-iii</p>
          </item>
        </blockList>
XML
    ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="list0">
              <item id="list0.a">
                <num>(a)</num>
                <p>foo</p>
              </item>
              <item id="list0.b">
                <num>(b)</num>
                <blockList id="list0.b.list0">
                  <listIntroduction>item-b</listIntroduction>
                  <item id="list0.b.list0.i">
                    <num>(i)</num>
                    <blockList id="list0.b.list0.i.list0">
                      <listIntroduction>item-b-i</listIntroduction>
                      <item id="list0.b.list0.i.list0.aa">
                        <num>(aa)</num>
                        <p>item-i-aa</p>
                      </item>
                      <item id="list0.b.list0.i.list0.bb">
                        <num>(bb)</num>
                        <p>item-i-bb</p>
                      </item>
                    </blockList>
                  </item>
                  <item id="list0.b.list0.ii">
                    <num>(ii)</num>
                    <p>item-b-ii</p>
                  </item>
                </blockList>
              </item>
              <item id="list0.c">
                <num>(c)</num>
                <blockList id="list0.c.list1">
                  <listIntroduction>item-c</listIntroduction>
                  <item id="list0.c.list1.i">
                    <num>(i)</num>
                    <p>item-c-i</p>
                  </item>
                  <item id="list0.c.list1.ii">
                    <num>(ii)</num>
                    <p>item-c-ii</p>
                  </item>
                  <item id="list0.c.list1.iii">
                    <num>(iii)</num>
                    <p>item-c-iii</p>
                  </item>
                </blockList>
              </item>
            </blockList>
XML
        )
    end

    # -------------------------------------------------------------------------

    it 'should jump back up a level when finding (i) near (h)' do
      doc = xml2doc(subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.h">
                <num>(h)</num>
                <p>foo</p>
              </item>
              <item id="section-10.1.lst0.i">
                <num>(i)</num>
                <p>item-i</p>
              </item>
              <item id="section-10.1.lst0.ii">
                <num>(ii)</num>
                <p>item-ii</p>
              </item>
              <item id="section-10.1.lst0.i">
                <num>(i)</num>
                <p>item-i</p>
              </item>
            </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-10.1.lst0">
              <item id="section-10.1.lst0.h">
                <num>(h)</num>
                <blockList id="section-10.1.lst0.h.list0">
                  <listIntroduction>foo</listIntroduction>
                  <item id="section-10.1.lst0.h.list0.i">
                    <num>(i)</num>
                    <p>item-i</p>
                  </item>
                  <item id="section-10.1.lst0.h.list0.ii">
                    <num>(ii)</num>
                    <p>item-ii</p>
                  </item>
                </blockList>
              </item>
              <item id="section-10.1.lst0.i">
                <num>(i)</num>
                <p>item-i</p>
              </item>
            </blockList>
XML
      )
    end

    # -------------------------------------------------------------------------

    it 'should handle dotted numbers correctly' do
      doc = xml2doc(subsection(<<XML
            <blockList id="section-9.subsection-2.list2">
              <item id="section-9.subsection-2.list2.9.2.1">
                <num>9.2.1</num>
                <p>is incapable of trading because of an illness, provided that:</p>
              </item>
              <item id="section-9.subsection-2.list2.9.2.1.1">
                <num>9.2.1.1</num>
                <p>proof from a medical practitioner is provided to the City which certifies that the permit-holder is unable to trade; and</p>
              </item>
              <item id="section-9.subsection-2.list2.9.2.1.2">
                <num>9.2.1.2</num>
                <p>the dependent or assistant is only permitted to replace the permit-</p>
              </item>
            </blockList>
XML
      ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-9.subsection-2.list2">
              <item id="section-9.subsection-2.list2.9.2.1">
                <num>9.2.1</num>
                <blockList id="section-9.subsection-2.list2.9.2.1.list0">
                  <listIntroduction>is incapable of trading because of an illness, provided that:</listIntroduction>
                  <item id="section-9.subsection-2.list2.9.2.1.list0.9.2.1.1">
                    <num>9.2.1.1</num>
                    <p>proof from a medical practitioner is provided to the City which certifies that the permit-holder is unable to trade; and</p>
                  </item>
                  <item id="section-9.subsection-2.list2.9.2.1.list0.9.2.1.2">
                    <num>9.2.1.2</num>
                    <p>the dependent or assistant is only permitted to replace the permit-</p>
                  </item>
                </blockList>
              </item>
            </blockList>
XML
      )
    end

    it 'should handle p tags just before' do
      doc = xml2doc(subsection(<<XML
        <p>intro</p>
        <blockList id="section-10.1.lst0">
          <item id="section-10.1.lst0.a">
            <num>(a)</num>
            <p>foo</p>
          </item>
        </blockList>
XML
        ))

      subject.adjust_blocklists(doc)
      doc.to_s.should == subsection(<<XML
            <blockList id="section-10.1.lst0">
              <listIntroduction>intro</listIntroduction>
              <item id="section-10.1.lst0.a">
                <num>(a)</num>
                <p>foo</p>
              </item>
            </blockList>
XML
      )
    end
  end

  describe '#normalise_headings' do
    it 'should normalise ALL CAPS headings' do
      doc = xml2doc(section(<<XML
          <heading>DEFINITIONS FOR A.B.C.</heading>
          <content>
            <p></p>
          </content>
XML
      ))
      subject.normalise_headings(doc)
      doc.to_s.should == section(<<XML
        <heading>Definitions for a.b.c.</heading>
        <content>
          <p/>
        </content>
XML
      )
    end

    it 'should not normalise normal headings' do
      doc = xml2doc(section(<<XML
          <heading>Definitions for A.B.C.</heading>
          <content>
            <p></p>
          </content>
XML
      ))
      subject.normalise_headings(doc)
      doc.to_s.should == section(<<XML
        <heading>Definitions for A.B.C.</heading>
        <content>
          <p/>
        </content>
XML
      )
    end
  end

  describe '#preprocess' do
    it 'should split inline table cells into block table cells' do
      text = <<EOS
foo
| bar || baz

{|
| boom || one !! two
|-
| three
|}

xxx

{|
| colspan="2" | bar || baz
|}
EOS
      subject.preprocess(text).should == <<EOS
foo
| bar || baz

{|
| boom 
| one 
! two
|-
| three
|}

xxx

{|
| colspan="2" | bar 
| baz
|}
EOS
    end
  end
end
