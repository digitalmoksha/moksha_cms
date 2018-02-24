require 'builder'

#    Scio Excel Library
#
#    v.0.2.1
#
#    Copyright (c) Rolando Abarca Millán 2005-2006
#
#    rabarca@scio.cl
#
#    This library is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#    == Installation
#
#    Put this file in $Rails.root/lib, restart your server.
#
#    <b>NOTE</b>: this library will become a rails plugin in the near future

module Scio
  module Excel
    BORDER_ALL    = 0b1111
    BORDER_LEFT   = 0b0001
    BORDER_TOP    = 0b0010
    BORDER_RIGHT  = 0b0100
    BORDER_BOTTOM = 0b1000

    # = SimpleWorkbook
    # This is a one-sheet workbook. Really simple.
    # It allows you to create an excel workbook from an array of hashes
    #
    # == Example 1
    #
    #   # first, create the styles (You should check the default styles)
    #   st1 = Scio::Excel::SimpleStyle.new(:text => {:valign => "Top"},
    #                                      :borders => Scio::Excel::BORDER_ALL)
    #   st2 = Scio::Excel::SimpleStyle.new(:text => {:valign => "Top", :wrap => true},
    #                                      :borders => Scio::Excel::BORDER_ALL)
    #   st3 = Scio::Excel::SimpleStyle.new(:borders => Scio::Excel::BORDER_ALL,
    #                                      :bgcolor => "#666699",
    #                                      :font => {:bold => true, :color => "#ffffff"})
    #
    #   # now, create the columns. The order of appearance is the order in which you push them
    #   # to the array.
    #   columns = []
    #   columns << Scio::Excel::Column.new("Birthday", :width => 76.5, :cell_style => st1, :header_style => st3)
    #   columns << Scio::Excel::Column.new("Name", :width => 276.75, :cell_style => st1, :header_style => st3)
    #
    #   # next, create the data array
    #   rows = User.all.collect {|u| {"Birthday" => u.bday.strftime("%d/%m/%Y"), "Name" => u.name}}
    #
    #   # create the workbook
    #   wb = Scio::Excel::SimpleWorkbook.new("User's birthday List")
    #   wb.columns = columns
    #   wb.rows = rows
    #
    #   # finally, send the workbook to the browser
    #   headers['Content-type'] = "application/vnd.ms-excel"
    #   render_text(e.create)
    #
    # == Example 2 (Default Styles & PDF Output)
    #
    # (needs fpdf for the PDF output)
    #
    #   wb = Scio::Excel::SimpleWorkbook.new("test de excel")
    #
    #   # create styles
    #   sth = Scio::Excel::SimpleStyle.new
    #   sth.text[:halign] = "Center"
    #   sth.font[:bold] = true
    #   sth.bgcolor = "#CCFFCC"
    #   sth.borders = Scio::Excel::BORDER_TOP | Scio::Excel::BORDER_BOTTOM
    #   stc = wb.default_cell_style
    #   stc.font[:italic] = true
    #   stc.text[:halign] = "Left"
    #
    #   # create the columns
    #   columns = []
    #   columns << Scio::Excel::Column.new("Nombre Cliente", :width => 150, :header_style => sth)
    #   columns << Scio::Excel::Column.new("R.U.T", :width => 40, :header_style => sth)
    #
    #   # crear the data
    #   rows = Cliente.order('razon_social').collect {|c|
    #     {"Nombre Cliente" => c.razon_social, "R.U.T" => c.rut}
    #   }
    #
    #   # set columns and rows
    #   wb.columns = columns
    #   wb.rows = rows
    #   send_data wb.create_pdf, :filename => "something.pdf", :type => "application/pdf"
    #
    # == Attributes
    #
    # +columns+:: array of Column
    # +rows+:: array of Hashes, each one representing a row. The key for the Hash must be
    #          the name of the corresponding column.
    # +name+:: name of the workbook. This will be the name of the single worksheet.
    # +row_height+:: set this to the height of the data rows.
    #
    # == Inspiration
    #
    # This library was inspired by the Excel Export Plugin:
    #
    # http://www.napcsweb.com/blog/2006/02/10/excel-plugin-10
    class SimpleWorkbook
      attr_accessor :columns,
                    :rows,
                    :name,
                    :row_height

      def initialize(name)
        @name       = name
        @columns    = []
        @rows       = []
        @row_height = nil
        @style_id   = 0
      end

      # Creates the xml text of the Workbook. You can send it to the browser
      # using <tt>render_text</tt>. You might need to set the HTTP headers
      # before.
      #
      # == Example
      #
      #   wb = Scio::Excel::Workbook.new("list")
      #   ...
      #   render_text(wb.create)
      def create
        buffer = ""
        xml = Builder::XmlMarkup.new(:target => buffer, :indent => 2)
        xml.instruct! :xml, :version => "1.0", :encoding => "UTF-8"
        xml.Workbook({
                       'xmlns'      => "urn:schemas-microsoft-com:office:spreadsheet",
                       'xmlns:o'    => "urn:schemas-microsoft-com:office:office",
                       'xmlns:x'    => "urn:schemas-microsoft-com:office:excel",
                       'xmlns:html' => "http://www.w3.org/TR/REC-html40",
                       'xmlns:ss'   => "urn:schemas-microsoft-com:office:spreadsheet"
                     }) do
          # add styles to the workbook
          styles = []
          @columns.each do |c|
            # use the default style if none set
            hstyle = c.header_style.nil? ? default_header_style : c.header_style
            cstyle = c.cell_style.nil? ? default_cell_style : c.cell_style
            # set the style, in case it's the default one
            c.header_style = hstyle
            c.cell_style = cstyle
            styles << hstyle unless styles.include?(hstyle)
            styles << cstyle unless styles.include?(cstyle)
          end
          xml.Styles do
            xml.Style 'ss:ID' => 'Default', 'ss:Name' => 'Normal' do
              xml.Alignment 'ss:Vertical' => 'Bottom'
              xml.Borders
              xml.Font 'ss:FontName' => 'Arial'
              xml.Interior
              xml.NumberFormat
              xml.Protection
            end
            styles.each do |s|
              xml << s.create(self)
            end
          end
          xml << create_worksheet(@name)
          # reset the styles-id
          @style_id = 0
        end # Workbook
      end

      # attempt to create a pdf for the table.
      #
      # == Example
      #
      #   wb = Scio::Excel::Workbook.new("customers")
      #   ...
      #   send_data wb.create_pdf, :filename => "something.pdf", :type => "application/pdf"
      #
      # One thing to note is that you <b>must</b> specify a width for each
      # column, and that the units for the columns are different than those
      # for excel (i.e: specify smaller numbers).
      #
      # This requires fpdf (http://zeropluszero.com/software/fpdf/)
      def create_pdf(orientation = "L")
        require 'fpdf'
        raise "Invalid orientation" if !["L", "P"].include?(orientation)

        pdf = FPDF.new
        # default font
        pdf.SetFont('Arial', '', 14)
        pdf.AddPage(orientation)
        # first, create the headers
        @columns.each do |c|
          # set the style
          hstyle = c.header_style.nil? ? default_header_style : c.header_style
          rgb = begin
                  hstyle.bgcolor.to_rgb
                rescue StandardError
                  nil
                end
          fill = 0
          unless rgb.nil?
            pdf.SetFillColor(rgb[:red], rgb[:green], rgb[:blue])
            fill = 1
          end
          rgb = begin
                  hstyle.font[:color].to_rgb
                rescue StandardError
                  nil
                end
          pdf.SetTextColor(rgb[:red], rgb[:green], rgb[:blue]) unless rgb.nil?
          fstyle = ''
          fstyle << "B" if hstyle.font[:bold]
          fstyle << "I" if hstyle.font[:italic]
          pdf.SetFont('', fstyle)
          border = 0
          if hstyle.borders > 0
            if hstyle.borders == BORDER_ALL
              border = 1
            else
              border = ''
              border << "T" if hstyle.borders & BORDER_TOP > 0
              border << "B" if hstyle.borders & BORDER_BOTTOM > 0
              border << "L" if hstyle.borders & BORDER_LEFT > 0
              border << "R" if hstyle.borders & BORDER_RIGHT > 0
            end
          end
          align = "C"
          unless hstyle.text[:align].nil?
            align = "L" if hstyle.text[:halign] == "Left"
            align = "R" if hstyle.text[:halign] == "Right"
          end
          # draw the cells
          pdf.Cell(c.width, 7, c.name, border, 0, align, fill)
        end # headers
        pdf.Ln

        # reset the styles
        pdf.SetTextColor(0, 0, 0)
        pdf.SetFont('', '')

        # draw the rows
        @rows.each do |r|
          # set the style
          @columns.each do |c|
            cstyle = c.cell_style.nil? ? default_cell_style : c.cell_style
            rgb = begin
                    cstyle.bgcolor.to_rgb
                  rescue StandardError
                    nil
                  end
            fill = 0
            unless rgb.nil?
              pdf.SetFillColor(rgb[:red], rgb[:green], rgb[:blue])
              fill = 1
            end
            rgb = begin
                    cstyle.font[:color].to_rgb
                  rescue StandardError
                    nil
                  end
            pdf.SetTextColor(rgb[:red], rgb[:green], rgb[:blue]) unless rgb.nil?
            fstyle = ''
            fstyle << "B" if cstyle.font[:bold]
            fstyle << "I" if cstyle.font[:italic]
            pdf.SetFont('', fstyle)
            border = 0
            if cstyle.borders > 0
              if cstyle.borders == BORDER_ALL
                border = 1
              else
                border = ''
                border << "T" if cstyle.borders & BORDER_TOP > 0
                border << "B" if cstyle.borders & BORDER_BOTTOM > 0
                border << "L" if cstyle.borders & BORDER_LEFT > 0
                border << "R" if cstyle.borders & BORDER_RIGHT > 0
              end
            end
            align = "C"
            unless cstyle.text[:align].nil?
              align = "L" if cstyle.text[:halign] == "Left"
              align = "R" if cstyle.text[:halign] == "Right"
            end
            pdf.Cell(c.width, 7, r[c.name], border, 0, align, fill)
          end # columns
          pdf.Ln
        end # rows

        # salida
        pdf.Output
      end

      # creates a default style for the header. This is used in case you don't
      # set a style for the column. If you really want a "plain" style, create
      # a column with an empty one:
      #
      #   nst = Scio::Excel::SimpleStyle.new
      #   col = Scio::Excel::Column.new("name", :header_style => nst)
      #
      # Since the default style is an instance variable, you don't need to set the
      # style for a column if you modify it.
      #
      # == Example
      #
      #   wb = Scio::Excel::SimpleWorkbook.new("user list")
      #   sth = wb.default_header_style
      #   sth.bgcolor = "#CCFFCC"
      #   columns = []
      #   # when rendering, the columns will use the default header style, but with a
      #   # bgcolor = #CCFFCC.
      #   columns << Scio::Excel::Column.new("User Name", :width => 276.75)
      #   columns << Scio::Excel::Column.new("Birthday", :width => 76.5)
      #
      # The same applies for the default_cell_style.
      def default_header_style
        if @default_header_style.nil?
          st = SimpleStyle.new
          st.font[:bold] = true
          st.font[:color] = "#FFFFFF"
          st.borders = BORDER_ALL
          st.text[:halign] = "Center"
          st.bgcolor = "#666699"
          @default_header_style = st
        end
        @default_header_style
      end

      # creates a default style for the cell. See default_header_style for documentation.
      def default_cell_style
        if @default_cell_style.nil?
          st = SimpleStyle.new
          st.borders = BORDER_ALL
          st.text[:valign] = "Center"
          @default_cell_style = st
        end
        @default_cell_style
      end

      def next_style_id #:nodoc:
        @style_id += 1
        "s#{@style_id}"
      end

      protected

      def create_worksheet(name) #:nodoc:
        buffer = ""
        xml = Builder::XmlMarkup.new(:target => buffer, :indent => 2)
        xml.Worksheet 'ss:Name' => name do
          xml.Table do
            # create header
            @columns.each do |c|
              col_opts = {}
              if !c.width.nil? && c.width > 0
                col_opts['ss:AutoFitWidth'] = "0"
                col_opts['ss:Width'] = c.width
              end
              xml.Column col_opts
            end
            xml.Row do
              @columns.each do |c|
                col_opts = {}
                col_opts['ss:StyleID'] = c.header_style.excel_id unless c.header_style.nil?
                xml.Cell col_opts do
                  xml.Data c.name, 'ss:Type' => 'String'
                end
              end
            end
            # now, add data :-)
            @rows.each do |r|
              row_opts = {}
              row_opts["ss:AutoFitHeight"] = "0"
              row_opts["ss:Height"] = @row_height unless @row_height.nil?
              xml.Row row_opts do
                @columns.each do |c|
                  cell_opts = {}
                  cell_opts["ss:StyleID"] = c.cell_style.excel_id unless c.cell_style.nil?
                  xml.Cell cell_opts do
                    unless r[c.name].blank?
                      xml.Data r[c.name], 'ss:Type' => c.type
                    end
                  end
                end
              end
            end # rows
          end # Table
        end # Worksheet
        xml.target!
      end
    end # SimpleWorkbook

    # Defines a Column for the data. You can set different styles for the
    # header and the cells.
    #
    # You can also set the width of the column.
    class Column
      attr_accessor :name,
                    :header_style,
                    :cell_style,
                    :width,
                    :type
      def initialize(name, opts = {})
        @name = name
        @header_style = opts[:header_style]
        @cell_style = opts[:cell_style]
        @width = opts[:width]
        @type = opts[:type].nil? ? 'String' : opts[:type]
      end
    end

    # SimpleStyle tries to simplify the styles for an individual cell.
    #
    # Current options are:
    #
    # * text alignment (vertical, horizontal)
    # * text wrapping
    # * font style (bold, italics, color)
    # * background color for the cell
    # * borders
    #
    # == Example
    #
    #   # simple center-align
    #   st1 = Scio::Excel::SimpleStyle.new(:text => {:halign => "Center"})
    #   # wrap text to the cell
    #   st2 = Scio::Excel::SimpleStyle.new(:text => {:wrap => true})
    #   # set background color
    #   st2.bgcolor = "#666699"
    #   # set the borders
    #   st2.borders = Scio::Excel::BORDER_ALL
    #   # set only the left & right border
    #   st1.borders = Scio::Excel::BORDER_LEFT | Scio::Excel::BORDER_RIGHT
    #   # italics
    #   st1.font[:italic] = true
    class SimpleStyle
      attr_accessor :text,
                    :font,
                    :borders,
                    :excel_id,
                    :bgcolor,
                    :numberformat

      def initialize(opts = {})
        @text         = opts[:text] || {}
        @font         = opts[:font] || {}
        @borders      = opts[:borders].nil? ? 0 : opts[:borders]
        @bgcolor      = opts[:bgcolor]
        @numberformat = opts[:numberformat]
      end

      # Creates the xml for the style. You should not call this directly.
      def create(workbook)
        buffer = ""
        xml = Builder::XmlMarkup.new(:target => buffer, :indent => 2)
        @excel_id = workbook.next_style_id
        xml.Style 'ss:ID' => @excel_id do
          unless @text.empty?
            alignment_opts = {}
            alignment_opts["ss:Vertical"] = @text[:valign] if !@text[:valign].nil?
            alignment_opts["ss:Horizontal"] = @text[:halign] if !@text[:halign].nil?
            alignment_opts["ss:WrapText"] = "1" if @text[:wrap]
            xml.Alignment alignment_opts unless alignment_opts.empty?
          end
          unless @font.empty?
            font_opts = {}
            font_opts["ss:Bold"] = "1" if @font[:bold]
            font_opts["ss:Italic"] = "1" if @font[:italic]
            font_opts["ss:Color"] = @font[:color] unless @font[:color].nil?
            xml.Font font_opts unless font_opts.empty?
          end
          if @borders > 0
            xml.Borders do
              xml.Border "ss:Position" => "Bottom",
                         "ss:LineStyle" => "Continuous",
                         "ss:Weight" => "1" if @borders & BORDER_BOTTOM > 0
              xml.Border "ss:Position" => "Left",
                         "ss:LineStyle" => "Continuous",
                         "ss:Weight" => "1" if @borders & BORDER_LEFT > 0
              xml.Border "ss:Position" => "Right",
                         "ss:LineStyle" => "Continuous",
                         "ss:Weight" => "1" if @borders & BORDER_RIGHT > 0
              xml.Border "ss:Position" => "Top",
                         "ss:LineStyle" => "Continuous",
                         "ss:Weight" => "1" if @borders & BORDER_TOP > 0
            end
          end
          xml.Interior "ss:Color" => @bgcolor, "ss:Pattern" => "Solid" unless @bgcolor.nil?
          xml.NumberFormat "ss:Format" => @numberformat unless @numberformat.nil?
        end
        xml.target!
      end
    end # SimpleStyle
  end
end

class String
  # simple (and naive) way to convert html-hex color to array of colors
  def to_rgb
    raise "Invalid Hex Color" if size != 7 || self[0] != 35

    rgb = Hash.new
    rgb[:red]   = self[1, 2].to_i(16)
    rgb[:green] = self[3, 2].to_i(16)
    rgb[:blue]  = self[5, 2].to_i(16)
    rgb
  end
end
