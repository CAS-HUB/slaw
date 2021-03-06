# encoding: UTF-8

require 'slaw'

describe Slaw::ActGenerator do
  subject { Slaw::ActGenerator.new('pl') }

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

  #-------------------------------------------------------------------------------
  # Basics

  describe 'full test' do
    it 'should handle a full hierarchy' do
      node = parse :body, <<EOS
DZIAŁ I

Projekt ustawy

Rozdział 7. Oznaczanie przepisów ustawy i ich systematyzacja

§ 54. Podstawową jednostką redakcyjną ustawy jest artykuł.

§ 55.
1. Każdą samodzielną myśl ujmuje się w odrębny artykuł.
2. Artykuł powinien być w miarę możliwości jednozdaniowy.
3. Jeżeli samodzielną myśl wyraża zespół zdań, dokonuje się podziału artykułu na ustępy. W ustawie określanej jako "kodeks" ustępy oznacza się paragrafami (§).
4. Podział artykułu na ustępy wprowadza się także w przypadku, gdy między zdaniami wyrażającymi samodzielne myśli występują powiązania treściowe, ale treść żadnego z nich nie jest na tyle istotna, aby wydzielić ją w odrębny artykuł.

§ 56.
1. W obrębie artykułu (ustępu) zawierającego wyliczenie wyróżnia się dwie części: wprowadzenie do wyliczenia oraz punkty. Wyliczenie może kończyć się częścią wspólną, odnoszącą się do wszystkich punktów. Po części wspólnej nie dodaje się kolejnej samodzielnej myśli; w razie potrzeby formułuje się ją w kolejnym ustępie.
2. W obrębie punktów można dokonać dalszego wyliczenia, wprowadzając litery.
EOS

      to_xml(node).should == '<body>
  <division id="division-I">
    <num>I</num>
    <subparagraph id="division-I.subparagraph-0">
      <content>
        <p>Projekt ustawy</p>
      </content>
    </subparagraph>
    <chapter id="chapter-7">
      <num>7</num>
      <heading>Oznaczanie przepisów ustawy i ich systematyzacja</heading>
      <section id="section-54">
        <num>54.</num>
        <content>
          <p>Podstawową jednostką redakcyjną ustawy jest artykuł.</p>
        </content>
      </section>
      <section id="section-55">
        <num>55.</num>
        <paragraph id="section-55.paragraph-1">
          <num>1.</num>
          <content>
            <p>Każdą samodzielną myśl ujmuje się w odrębny artykuł.</p>
          </content>
        </paragraph>
        <paragraph id="section-55.paragraph-2">
          <num>2.</num>
          <content>
            <p>Artykuł powinien być w miarę możliwości jednozdaniowy.</p>
          </content>
        </paragraph>
        <paragraph id="section-55.paragraph-3">
          <num>3.</num>
          <content>
            <p>Jeżeli samodzielną myśl wyraża zespół zdań, dokonuje się podziału artykułu na ustępy. W ustawie określanej jako "kodeks" ustępy oznacza się paragrafami (§).</p>
          </content>
        </paragraph>
        <paragraph id="section-55.paragraph-4">
          <num>4.</num>
          <content>
            <p>Podział artykułu na ustępy wprowadza się także w przypadku, gdy między zdaniami wyrażającymi samodzielne myśli występują powiązania treściowe, ale treść żadnego z nich nie jest na tyle istotna, aby wydzielić ją w odrębny artykuł.</p>
          </content>
        </paragraph>
      </section>
      <section id="section-56">
        <num>56.</num>
        <paragraph id="section-56.paragraph-1">
          <num>1.</num>
          <content>
            <p>W obrębie artykułu (ustępu) zawierającego wyliczenie wyróżnia się dwie części: wprowadzenie do wyliczenia oraz punkty. Wyliczenie może kończyć się częścią wspólną, odnoszącą się do wszystkich punktów. Po części wspólnej nie dodaje się kolejnej samodzielnej myśli; w razie potrzeby formułuje się ją w kolejnym ustępie.</p>
          </content>
        </paragraph>
        <paragraph id="section-56.paragraph-2">
          <num>2.</num>
          <content>
            <p>W obrębie punktów można dokonać dalszego wyliczenia, wprowadzając litery.</p>
          </content>
        </paragraph>
      </section>
    </chapter>
  </division>
</body>'
    end
  end

  #-------------------------------------------------------------------------------
  # Articles

  describe 'articles' do
    it 'should handle articles' do
      node = parse :article, <<EOS
Art. 1. Ustawa reguluje opodatkowanie podatkiem dochodowym dochodów osób fizycznych
EOS
      to_xml(node).should == '<article id="article-1">
  <num>1.</num>
  <content>
    <p>Ustawa reguluje opodatkowanie podatkiem dochodowym dochodów osób fizycznych</p>
  </content>
</article>'
    end

    it 'should handle articles with blank lines' do
      node = parse :article, <<EOS
Art. 1.

Ustawa reguluje opodatkowanie podatkiem dochodowym dochodów osób fizycznych
EOS
      to_xml(node).should == '<article id="article-1">
  <num>1.</num>
  <content>
    <p>Ustawa reguluje opodatkowanie podatkiem dochodowym dochodów osób fizycznych</p>
  </content>
</article>'
    end

    it 'should handle consecutive articles' do
      node = parse :body, <<EOS
Art. 1. Ustawa reguluje opodatkowanie podatkiem dochodowym dochodów osób fizycznych
Art. 2. Something else
EOS
      to_xml(node).should == '<body>
  <article id="article-1">
    <num>1.</num>
    <content>
      <p>Ustawa reguluje opodatkowanie podatkiem dochodowym dochodów osób fizycznych</p>
    </content>
  </article>
  <article id="article-2">
    <num>2.</num>
    <content>
      <p>Something else</p>
    </content>
  </article>
</body>'
    end

    it 'should handle nested content' do
      node = parse :article, <<EOS
Art. 2.
1. Przepisów ustawy nie stosuje się do:
1) przychodów z działalności rolniczej, z wyjątkiem przychodów z działów specjalnych produkcji rolnej;
2) przychodów z gospodarki leśnej w rozumieniu ustawy o lasach;
EOS
      to_xml(node).should == '<article id="article-2">
  <num>2.</num>
  <paragraph id="article-2.paragraph-1">
    <num>1.</num>
    <intro>
      <p>Przepisów ustawy nie stosuje się do:</p>
    </intro>
    <point id="article-2.paragraph-1.point-1">
      <num>1)</num>
      <content>
        <p>przychodów z działalności rolniczej, z wyjątkiem przychodów z działów specjalnych produkcji rolnej;</p>
      </content>
    </point>
    <point id="article-2.paragraph-1.point-2">
      <num>2)</num>
      <content>
        <p>przychodów z gospodarki leśnej w rozumieniu ustawy o lasach;</p>
      </content>
    </point>
  </paragraph>
</article>'
    end
  end

  #-------------------------------------------------------------------------------
  # Divisions

  describe 'divisions' do
    it 'should handle divisions' do
      node = parse :division, <<EOS
DZIAŁ I
Projekt ustawy

Rozdział 7. Oznaczanie przepisów ustawy i ich systematyzacja

§ 54. Podstawową jednostką redakcyjną ustawy jest artykuł.
EOS
      to_xml(node).should == '<division id="division-I">
  <num>I</num>
  <heading>Projekt ustawy</heading>
  <chapter id="chapter-7">
    <num>7</num>
    <heading>Oznaczanie przepisów ustawy i ich systematyzacja</heading>
    <section id="section-54">
      <num>54.</num>
      <content>
        <p>Podstawową jednostką redakcyjną ustawy jest artykuł.</p>
      </content>
    </section>
  </chapter>
</division>'
    end
  end

  #-------------------------------------------------------------------------------
  # Subdivisions

  describe 'subdivisions' do
    it 'should handle subdivisions' do
      node = parse :subdivision, <<EOS
ODDZIAŁ I
Projekt ustawy

§ 54. Podstawową jednostką redakcyjną ustawy jest artykuł.
EOS
      to_xml(node).should == '<subdivision id="subdivision-I">
  <num>I</num>
  <heading>Projekt ustawy</heading>
  <section id="section-54">
    <num>54.</num>
    <content>
      <p>Podstawową jednostką redakcyjną ustawy jest artykuł.</p>
    </content>
  </section>
</subdivision>'
    end
  end

  #-------------------------------------------------------------------------------
  # Paragraph

  describe 'paragraph' do
    it 'should handle simple para' do
      node = parse :paragraph, <<EOS
1. Każdą samodzielną myśl ujmuje się w odrębny artykuł.
EOS

      to_xml(node).should == '<paragraph id="paragraph-1">
  <num>1.</num>
  <content>
    <p>Każdą samodzielną myśl ujmuje się w odrębny artykuł.</p>
  </content>
</paragraph>'
    end

    it 'should handle an empty para' do
      node = parse :paragraph, <<EOS
1.
EOS

      to_xml(node).should == '<paragraph id="paragraph-1">
  <num>1.</num>
  <content>
    <p/>
  </content>
</paragraph>'
    end

    it 'should handle a para with whitespace' do
      node = parse :paragraph, <<EOS
1.

foo bar
EOS

      to_xml(node).should == '<paragraph id="paragraph-1">
  <num>1.</num>
  <content>
    <p>foo bar</p>
  </content>
</paragraph>'
    end

    it 'should handle paragraphs with points' do
      node = parse :paragraph, <<EOS
2. W ustawie należy unikać posługiwania się:
1) określeniami specjalistycznymi, o ile ich użycie nie jest powodowane zapewnieniem należytej precyzji tekstu;
2) określeniami lub zapożyczeniami obcojęzycznymi, chyba że nie mają dokładnego odpowiednika w języku polskim;
3) nowo tworzonymi pojęciami lub strukturami językowymi, chyba że w dotychczasowym słownictwie polskim brak jest odpowiedniego określenia.
EOS

      to_xml(node).should == '<paragraph id="paragraph-2">
  <num>2.</num>
  <intro>
    <p>W ustawie należy unikać posługiwania się:</p>
  </intro>
  <point id="paragraph-2.point-1">
    <num>1)</num>
    <content>
      <p>określeniami specjalistycznymi, o ile ich użycie nie jest powodowane zapewnieniem należytej precyzji tekstu;</p>
    </content>
  </point>
  <point id="paragraph-2.point-2">
    <num>2)</num>
    <content>
      <p>określeniami lub zapożyczeniami obcojęzycznymi, chyba że nie mają dokładnego odpowiednika w języku polskim;</p>
    </content>
  </point>
  <point id="paragraph-2.point-3">
    <num>3)</num>
    <content>
      <p>nowo tworzonymi pojęciami lub strukturami językowymi, chyba że w dotychczasowym słownictwie polskim brak jest odpowiedniego określenia.</p>
    </content>
  </point>
</paragraph>'
    end

    it 'should not get confused by points with articles' do
      node = parse :paragraph, <<EOS
2. W ustawie należy unikać posługiwania się:
1) art. 1
2) art. 2
EOS

      to_xml(node).should == '<paragraph id="paragraph-2">
  <num>2.</num>
  <intro>
    <p>W ustawie należy unikać posługiwania się:</p>
  </intro>
  <point id="paragraph-2.point-1">
    <num>1)</num>
    <content>
      <p>art. 1</p>
    </content>
  </point>
  <point id="paragraph-2.point-2">
    <num>2)</num>
    <content>
      <p>art. 2</p>
    </content>
  </point>
</paragraph>'
    end
  end

  #-------------------------------------------------------------------------------
  # Section

  describe 'section' do
    it 'should handle section with un-numbered para' do
      node = parse :section, <<EOS
§ 5.

Przepisy ustawy redaguje si´ zwi´êle i syntetycznie, unikajàc nadmiernej szczegó∏owoÊci, a zarazem w sposób, w jaki opisuje si´ typowe sytuacje wyst´pujàce w dziedzinie spraw regulowanych tà ustawà.
EOS

      to_xml(node).should == '<section id="section-5">
  <num>5.</num>
  <content>
    <p>Przepisy ustawy redaguje si´ zwi´êle i syntetycznie, unikajàc nadmiernej szczegó∏owoÊci, a zarazem w sposób, w jaki opisuje si´ typowe sytuacje wyst´pujàce w dziedzinie spraw regulowanych tà ustawà.</p>
  </content>
</section>'
    end

    it 'should handle section with numbered para on the same line' do
      node = parse :section, <<EOS
§ 54. Podstawową jednostką redakcyjną ustawy jest artykuł.
EOS

      to_xml(node).should == '<section id="section-54">
  <num>54.</num>
  <content>
    <p>Podstawową jednostką redakcyjną ustawy jest artykuł.</p>
  </content>
</section>'
    end

    it 'should handle section with numbered paras' do
      node = parse :section, <<EOS
§ 55.
1. Każdą samodzielną myśl ujmuje się w odrębny artykuł.
2. Artykuł powinien być w miarę możliwości jednozdaniowy.
3. Jeżeli samodzielną myśl wyraża zespół zdań, dokonuje się podziału artykułu na ustępy. W ustawie określanej jako "kodeks" ustępy oznacza się paragrafami (§).
EOS

      to_xml(node).should == '<section id="section-55">
  <num>55.</num>
  <paragraph id="section-55.paragraph-1">
    <num>1.</num>
    <content>
      <p>Każdą samodzielną myśl ujmuje się w odrębny artykuł.</p>
    </content>
  </paragraph>
  <paragraph id="section-55.paragraph-2">
    <num>2.</num>
    <content>
      <p>Artykuł powinien być w miarę możliwości jednozdaniowy.</p>
    </content>
  </paragraph>
  <paragraph id="section-55.paragraph-3">
    <num>3.</num>
    <content>
      <p>Jeżeli samodzielną myśl wyraża zespół zdań, dokonuje się podziału artykułu na ustępy. W ustawie określanej jako "kodeks" ustępy oznacza się paragrafami (§).</p>
    </content>
  </paragraph>
</section>'
    end

    it 'should not confuse section content with block elements' do
      node = parse :section, <<EOS
§ 55. 1. Każdą samodzielną myśl ujmuje się w odrębny artykuł.
3. Jeżeli samodzielną myśl wyraża zespół zdań, dokonuje się podziału artykułu na ustępy. W ustawie określanej jako "kodeks" ustępy oznacza się paragrafami (§).
EOS

      to_xml(node).should == '<section id="section-55">
  <num>55.</num>
  <intro>
    <p>1. Każdą samodzielną myśl ujmuje się w odrębny artykuł.</p>
  </intro>
  <paragraph id="section-55.paragraph-3">
    <num>3.</num>
    <content>
      <p>Jeżeli samodzielną myśl wyraża zespół zdań, dokonuje się podziału artykułu na ustępy. W ustawie określanej jako "kodeks" ustępy oznacza się paragrafami (§).</p>
    </content>
  </paragraph>
</section>'
    end

    it 'should handle section with intro, para and points' do
      node = parse :section, <<EOS
§ 54. Podstawową jednostką redakcyjną ustawy jest artykuł.

Something here

1) a point
2) second point
EOS

      to_xml(node).should == '<section id="section-54">
  <num>54.</num>
  <intro>
    <p>Podstawową jednostką redakcyjną ustawy jest artykuł.</p>
  </intro>
  <subparagraph id="section-54.subparagraph-0">
    <content>
      <p>Something here</p>
    </content>
  </subparagraph>
  <point id="section-54.point-1">
    <num>1)</num>
    <content>
      <p>a point</p>
    </content>
  </point>
  <point id="section-54.point-2">
    <num>2)</num>
    <content>
      <p>second point</p>
    </content>
  </point>
</section>'
    end

    it 'should not get confused by sections with articles' do
      node = parse :section, <<EOS
§ 54. Art 1. is changed...
EOS

      to_xml(node).should == '<section id="section-54">
  <num>54.</num>
  <content>
    <p>Art 1. is changed...</p>
  </content>
</section>'
    end
  end

  #-------------------------------------------------------------------------------
  # Point

  describe 'point' do
    it 'should handle basic point' do
      node = parse :point, <<EOS
1) szczegółowy tryb i terminy rozpatrywania wniosków o udzielenie finansowego wsparcia;
EOS

      to_xml(node, 'prefix.', 0).should == '<point id="prefix.point-1">
  <num>1)</num>
  <content>
    <p>szczegółowy tryb i terminy rozpatrywania wniosków o udzielenie finansowego wsparcia;</p>
  </content>
</point>'
    end

    it 'should handle points with litera' do
      node = parse :point, <<EOS
1) dokumenty potwierdzające prawo własności albo prawo użytkowania wieczystego nieruchomości, której dotyczy przedsięwzięcie albo na której położony jest budynek, którego budowę, remont lub przebudowę zamierza się przepro- wadzić w ramach realizacji przedsięwzięcia, w tym:

a) oryginał albo potwierdzoną za zgodność z oryginałem kopię wypisu i wyrysu z rejestru gruntów wszystkich dzia- łek ewidencyjnych, na których realizowane jest przedsięwzięcie, wydanego nie wcześniej niż 3 miesiące przed dniem złożenia wniosku, oraz

b) numer księgi wieczystej;
EOS

      to_xml(node, 'prefix.', 0).should == '<point id="prefix.point-1">
  <num>1)</num>
  <intro>
    <p>dokumenty potwierdzające prawo własności albo prawo użytkowania wieczystego nieruchomości, której dotyczy przedsięwzięcie albo na której położony jest budynek, którego budowę, remont lub przebudowę zamierza się przepro- wadzić w ramach realizacji przedsięwzięcia, w tym:</p>
  </intro>
  <alinea id="prefix.point-1.alinea-a">
    <num>a)</num>
    <content>
      <p>oryginał albo potwierdzoną za zgodność z oryginałem kopię wypisu i wyrysu z rejestru gruntów wszystkich dzia- łek ewidencyjnych, na których realizowane jest przedsięwzięcie, wydanego nie wcześniej niż 3 miesiące przed dniem złożenia wniosku, oraz</p>
    </content>
  </alinea>
  <alinea id="prefix.point-1.alinea-b">
    <num>b)</num>
    <content>
      <p>numer księgi wieczystej;</p>
    </content>
  </alinea>
</point>'
    end
  end

  #-------------------------------------------------------------------------------
  # Litera

  describe 'litera' do

    it 'should handle litera with indents' do
      node = parse :litera, <<EOS
b) liczby:
- tworzonych lokali wchodzących w skład mieszkaniowego zasobu gminy,
- mieszkań chronionych,
- lokali mieszkalnych powstających z udziałem gminy albo związku międzygminnego w wyniku realizacji przedsięwzięć, o których mowa w art. 5 ust. 1 i art. 5a ust. 1 ustawy,
- tymczasowych pomieszczeń,
- miejsc w noclegowniach, schroniskach dla bezdomnych i ogrzewalniach,
EOS
      to_xml(node, 'prefix.', 0).should == '<alinea id="prefix.alinea-b">
  <num>b)</num>
  <intro>
    <p>liczby:</p>
  </intro>
  <list id="prefix.alinea-b.list-0">
    <indent id="prefix.alinea-b.list-0.indent-0">
      <content>
        <p>tworzonych lokali wchodzących w skład mieszkaniowego zasobu gminy,</p>
      </content>
    </indent>
    <indent id="prefix.alinea-b.list-0.indent-1">
      <content>
        <p>mieszkań chronionych,</p>
      </content>
    </indent>
    <indent id="prefix.alinea-b.list-0.indent-2">
      <content>
        <p>lokali mieszkalnych powstających z udziałem gminy albo związku międzygminnego w wyniku realizacji przedsięwzięć, o których mowa w art. 5 ust. 1 i art. 5a ust. 1 ustawy,</p>
      </content>
    </indent>
    <indent id="prefix.alinea-b.list-0.indent-3">
      <content>
        <p>tymczasowych pomieszczeń,</p>
      </content>
    </indent>
    <indent id="prefix.alinea-b.list-0.indent-4">
      <content>
        <p>miejsc w noclegowniach, schroniskach dla bezdomnych i ogrzewalniach,</p>
      </content>
    </indent>
  </list>
</alinea>'
    end
  end

  #-------------------------------------------------------------------------------
  # Indent

  describe 'indent' do
    it 'should handle basic indent' do
      node = parse :indents, <<EOS
- tworzonych lokali wchodzących w skład mieszkaniowego zasobu gminy,
EOS

      to_xml(node, 'prefix.', 0).should == '<list id="prefix.list-0">
  <indent id="prefix.list-0.indent-0">
    <content>
      <p>tworzonych lokali wchodzących w skład mieszkaniowego zasobu gminy,</p>
    </content>
  </indent>
</list>'
    end

    it 'should handle indents with different dash characters' do
      node = parse :indents, <<EOS
– foo
- bar
EOS

      to_xml(node, 'prefix.', 0).should == '<list id="prefix.list-0">
  <indent id="prefix.list-0.indent-0">
    <content>
      <p>foo</p>
    </content>
  </indent>
  <indent id="prefix.list-0.indent-1">
    <content>
      <p>bar</p>
    </content>
  </indent>
</list>'
    end

    it 'should handle empty indents' do
      node = parse :indents, <<EOS
- 
- 
EOS

      to_xml(node, 'prefix.', 0).should == '<list id="prefix.list-0">
  <indent id="prefix.list-0.indent-0">
    <content>
      <p/>
    </content>
  </indent>
  <indent id="prefix.list-0.indent-1">
    <content>
      <p/>
    </content>
  </indent>
</list>'
    end

    it 'should handle multiple indent items' do
      node = parse :indents, <<EOS
- tworzonych lokali wchodzących w skład mieszkaniowego zasobu gminy,
- mieszkań chronionych,
- lokali mieszkalnych powstających z udziałem gminy albo związku międzygminnego w wyniku realizacji przedsięwzięć, o których mowa w art. 5 ust. 1 i art. 5a ust. 1 ustawy,
EOS

      to_xml(node, 'prefix.', 0).should == '<list id="prefix.list-0">
  <indent id="prefix.list-0.indent-0">
    <content>
      <p>tworzonych lokali wchodzących w skład mieszkaniowego zasobu gminy,</p>
    </content>
  </indent>
  <indent id="prefix.list-0.indent-1">
    <content>
      <p>mieszkań chronionych,</p>
    </content>
  </indent>
  <indent id="prefix.list-0.indent-2">
    <content>
      <p>lokali mieszkalnych powstających z udziałem gminy albo związku międzygminnego w wyniku realizacji przedsięwzięć, o których mowa w art. 5 ust. 1 i art. 5a ust. 1 ustawy,</p>
    </content>
  </indent>
</list>'
    end
  end

end
