# encoding: UTF-8

require 'slaw'

describe Slaw::ActGenerator do
  subject { Slaw::ActGenerator.new('za') }

  def parse(rule, s)
    subject.builder.text_to_syntax_tree(s, {root: rule})
  end

  def should_parse(rule, s)
    s << "\n" unless s.end_with?("\n")
    tree = subject.builder.text_to_syntax_tree(s, {root: rule})

    if not tree
      raise Exception.new(subject.failure_reason || "Couldn't match to grammar") if tree.nil?
    else
      # count an assertion
      tree.should_not be_nil
    end
  end

  def to_xml(node, *args)
    b = ::Nokogiri::XML::Builder.new
    node.to_xml(b, *args)
    b.doc.root.to_xml(encoding: 'UTF-8')
  end

  describe 'tables' do
    it 'should parse basic tables' do
      node = parse :table, <<EOS
{|
! r1c1
| r1c2
|-
| r2c1
| r2c2
|}
EOS

      to_xml(node, "prefix.").should == '<table id="prefix.table0">
  <tr>
    <th>
      <p>r1c1</p>
    </th>
    <td>
      <p>r1c2</p>
    </td>
  </tr>
  <tr>
    <td>
      <p>r2c1</p>
    </td>
    <td>
      <p>r2c2</p>
    </td>
  </tr>
</table>'
    end

    it 'should handle tables with empty cells' do
      node = parse :table, <<EOS
{|
!
|
|-
|

| 
|-
|-
|}
EOS

      to_xml(node, "prefix.").should == '<table id="prefix.table0">
  <tr>
    <th>
      <p/>
    </th>
    <td>
      <p/>
    </td>
  </tr>
  <tr>
    <td>
      <p/>
    </td>
    <td>
      <p/>
    </td>
  </tr>
</table>'
    end

    it 'should parse table attributes' do
      node = parse :table, <<EOS
{|
| colspan="2" | r1c1
|  rowspan="1"  colspan='3' | r1c2
|-
|a="b"| r2c1
|a="b"c="d"  | r2c2
|}
EOS

      to_xml(node, "prefix.").should == '<table id="prefix.table0">
  <tr>
    <td colspan="2">
      <p>r1c1</p>
    </td>
    <td rowspan="1" colspan="3">
      <p>r1c2</p>
    </td>
  </tr>
  <tr>
    <td a="b">
      <p>r2c1</p>
    </td>
    <td a="b" c="d">
      <p>r2c2</p>
    </td>
  </tr>
</table>'
    end

    it 'should allow newlines in table cells' do
      node = parse :table, <<EOS
{|
| foo
bar

baz
|
 one
two

 three
|
  four

|-
|}
EOS

      to_xml(node, "prefix.").should == '<table id="prefix.table0">
  <tr>
    <td>
      <p>foo<eol/>bar<eol/><eol/>baz</p>
    </td>
    <td>
      <p>one<eol/>two<eol/><eol/>three</p>
    </td>
    <td>
      <p>four</p>
    </td>
  </tr>
</table>'
    end

    it 'should parse a table in a section' do
      node = parse :section, <<EOS
10. A section title

Heres a table:

{|
| r1c1
| r1c2
|-
| r2c1
| r2c2
|}
EOS

      xml = to_xml(node)
      xml.should == '<section id="section-10">
  <num>10.</num>
  <heading>A section title</heading>
  <paragraph id="section-10.paragraph-0">
    <content>
      <p>Heres a table:</p>
      <table id="section-10.paragraph-0.table1">
        <tr>
          <td>
            <p>r1c1</p>
          </td>
          <td>
            <p>r1c2</p>
          </td>
        </tr>
        <tr>
          <td>
            <p>r2c1</p>
          </td>
          <td>
            <p>r2c2</p>
          </td>
        </tr>
      </table>
    </content>
  </paragraph>
</section>'
    end

    it 'should parse a table in a schedule' do
      node = parse :schedule, <<EOS
Schedule 1

Heres a table:

{|
| r1c1
| r1c2
|-
| r2c1
| r2c2
|}
EOS

      xml = to_xml(node, "")
      today = Time.now.strftime('%Y-%m-%d')
      xml.should == '<component id="component-schedule1">
  <doc name="schedule1">
    <meta>
      <identification source="#slaw">
        <FRBRWork>
          <FRBRthis value="/za/act/1980/01/schedule1"/>
          <FRBRuri value="/za/act/1980/01"/>
          <FRBRalias value="Schedule 1"/>
          <FRBRdate date="1980-01-01" name="Generation"/>
          <FRBRauthor href="#council"/>
          <FRBRcountry value="za"/>
        </FRBRWork>
        <FRBRExpression>
          <FRBRthis value="/za/act/1980/01/eng@/schedule1"/>
          <FRBRuri value="/za/act/1980/01/eng@"/>
          <FRBRdate date="1980-01-01" name="Generation"/>
          <FRBRauthor href="#council"/>
          <FRBRlanguage language="eng"/>
        </FRBRExpression>
        <FRBRManifestation>
          <FRBRthis value="/za/act/1980/01/eng@/schedule1"/>
          <FRBRuri value="/za/act/1980/01/eng@"/>
          <FRBRdate date="' + today + '" name="Generation"/>
          <FRBRauthor href="#slaw"/>
        </FRBRManifestation>
      </identification>
    </meta>
    <mainBody>
      <article id="schedule1">
        <paragraph id="schedule1.paragraph-0">
          <content>
            <p>Heres a table:</p>
            <table id="schedule1.paragraph-0.table1">
              <tr>
                <td>
                  <p>r1c1</p>
                </td>
                <td>
                  <p>r1c2</p>
                </td>
              </tr>
              <tr>
                <td>
                  <p>r2c1</p>
                </td>
                <td>
                  <p>r2c2</p>
                </td>
              </tr>
            </table>
          </content>
        </paragraph>
      </article>
    </mainBody>
  </doc>
</component>'
    end

    it 'should ignore an escaped table' do
      node = parse :block_paragraphs, <<EOS
\\{|
| r1c1
| r1c2
|}
EOS

      to_xml(node).should == '<paragraph id="paragraph-0">
  <content>
    <p>{|</p>
    <p>| r1c1</p>
    <p>| r1c2</p>
    <p>|}</p>
  </content>
</paragraph>'
    end

    it 'should allow a table as part of a subsection' do
      node = parse :subsection, <<EOS
(1) {|
| foo
|}
EOS

      to_xml(node, '', 0).should == '<subsection id="1">
  <num>(1)</num>
  <content>
    <table id="1.table0">
      <tr>
        <td>
          <p>foo</p>
        </td>
      </tr>
    </table>
  </content>
</subsection>'
    end

    it 'should allow links in a table' do
      node = parse :table, <<EOS
{|
| a [link](/a/b) in a table
| [link](/a/b) and
[[comment]]
|}
EOS

      to_xml(node, '', 0).should == '<table id="table0">
  <tr>
    <td>
      <p>a <ref href="/a/b">link</ref> in a table</p>
    </td>
    <td>
      <p><ref href="/a/b">link</ref> and<eol/><remark status="editorial">[comment]</remark></p>
    </td>
  </tr>
</table>'
    end

    it 'should manage entities in a table' do
      node = parse :table, <<EOS
{|
| a > b
| c & d
|}
EOS

      to_xml(node, '', 0).should == '<table id="table0">
  <tr>
    <td>
      <p>a &gt; b</p>
    </td>
    <td>
      <p>c &amp; d</p>
    </td>
  </tr>
</table>'
    end
  end

end
