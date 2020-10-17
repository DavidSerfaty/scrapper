class Scrapper
  def get_townhall_urls
    townhall_urls = Nokogiri::HTML(URI.open('http://annuaire-des-mairies.com/val-d-oise.html'))
    townhall_urls.xpath('//a[@class="lientxt"]/@href')
  end

  def get_townhall_info_url(townhall_url)
    Nokogiri::HTML(URI.open('http://annuaire-des-mairies.com/' + townhall_url))
  end

  def get_townhall_email(townhall_url)
    get_townhall_info_url(townhall_url).xpath('//td[contains(text(),"@")]').text
  end

  def get_townhall_name(townhall_url)
    get_townhall_info_url(townhall_url).xpath('/html/body/div/main/section[1]/div/div/div/h1').text.split(' ').delete_at(0).downcase
  end

  def get_townhall_info
    @townhall_array = []
    get_townhall_urls.each do |town|
      townhall_hash = {}
      townhall_hash[get_townhall_name(town)] = get_townhall_email(town)
      @townhall_array << townhall_hash
      puts townhall_hash
    end
    return @townhall_array
  end

  def save_as_json
    File.open("db/emails.json","w") do |f|
      f.write(JSON.pretty_generate(@townhall_array))
    end
  end

  def save_as_csv
    results_for_csv = @townhall_array.map{|hash| hash.map{|k, v| [k, v]}}

    final_arr = results_for_csv.map { |data| data.join(",") }.join("\n")
    File.open("db/emails.csv", "a+") do |csv|
      csv << final_arr
    end
  end

  # def save_as_google_sheet
  #   session = GoogleDrive::Session.from_config("config.json")
  #   ws = session.spreadsheet_by_key("1IFDxbJVDZQRvXBiSsE8RSoFXNxoXq9J133DP-h9ttgw").worksheets[0]
  #   # Gets content of A2 cell.
  #   p ws[2, 1]  #==> "hoge"
  #
  #   # Changes content of cells.
  #   # Changes are not sent to the server until you call ws.save().
  #   ws[2, 1] = "foo"
  #   ws[2, 2] = "bar"
  #   ws.save
  #
  #   # Dumps all cells.
  #   (1..ws.num_rows).each do |row|
  #     (1..ws.num_cols).each do |col|
  #       p ws[row, col]
  #     end
  #   end
  #   # Yet another way to do so.
  #   p ws.rows  #==> [["fuga", ""], ["foo", "bar]]
  #
  #   # Reloads the worksheet to get changes by other clients.
  #   ws.reload
  # end

  def perform
    puts "Les emails arrivent"
    get_townhall_info
    puts "Tu peux les récupérer dans le dossier db aux formats json et csv"
    save_as_json
    save_as_csv
    #save_as_google_sheet
  end
end
