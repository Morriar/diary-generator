import template

# A Diary entry
class DiaryEntry
	super Template

	# Actual date
	var date: String

	# Entry text
	var content: Template

	# Imperial date
	var idate: String is lazy do
		var pr = new ProcessReader("./imperial_cal", date)
		var res = pr.read_all
		pr.close
		return res.trim
	end

	private var iparts: Array[String] is lazy do return idate.split_with(" ")

	var id: String is lazy do
		if iparts.length < 3 then return iparts[0].to_lower
		return if iparts[0].to_i >= 10 then iparts[0] else "0{iparts[0]}"
	end

	var im: String is lazy do
		if iparts.length < 3 then return iparts[0]
		return iparts[1]
	end

	var iy: String is lazy do
		if iparts.length < 3 then return iparts[1]
		return iparts[2]
	end

	fun save(dir: String) do
		sys.system "mkdir -p {dir}/{iy}/{im}"
		write_to_file("{dir}/{iy}/{im}/{id}.md")
	end

	redef fun rendering do
		addn "# {idate}"
		if im == "Dome" then
			addn "It's dome day... I'm happy! Have a flag: `UQAM\{SsxD5bPLRVaIz1\}`!"
		else if im == "Indium" and id == "27" then
			addn "It's my birthday, have a flag `UQAM\{9a01e81984202d0a5833\}`!"
		else
			addn content
		end
	end
end

class Diarygenerator

	var feels_dir: String

	var humors = new Array[String]
	var feelings = new HashMap[String, Array[String]]

	init do load_humors(feels_dir)

	private fun load_humors(dir: String) do
		for f in dir.files do
			if not f.has_suffix(".feel") then continue
			humors.add f
			load_feelings(dir / f, f)
		end
	end

	fun load_feelings(file: String, humor: String) do
		feelings[humor] = new Array[String]
		var fr = new FileReader.open(file)
		for line in fr.read_lines do
			feelings[humor].add line
		end
		fr.close
	end

	fun gen_diary(out_dir: String) do
		for y in [3009..3016] do
			for m in [1..12] do
				var sm = if m < 10 then "0{m}" else m.to_s
				for d in [1..31] do
					if m == 2 and d > 28 then break
					if m == 2 and d > 28 and y % 4 == 1 then break
					if d > 30 and ((m <= 7 and m % 2 == 0) or (m > 7 and m % 2 == 1)) then break
					var sd = if d < 10 then "0{d}" else d.to_s

					var date = "{y}/{sm}/{sd}"
					var entry = new_diary_entry(date)
					print entry.idate
					entry.save(out_dir)
				end
			end
		end
	end

	fun new_diary_entry(date: String): DiaryEntry do
		var tpl = new Template

		var humor = humors.rand
		for i in [0..15.rand] do
			if i > 0 then tpl.add " "
			tpl.add feelings[humor].rand
		end
		return new DiaryEntry(date, tpl)
	end
end

var gen = new Diarygenerator("feelings")
gen.gen_diary("out")
#TODO gen commits (author, date)
