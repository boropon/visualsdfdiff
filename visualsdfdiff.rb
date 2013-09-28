require 'nkf'

class ResultHTML
	
	def initialize()
		@srcLinenum = 1
		@tagnum = 1
	end
	
	# 結果出力用のHTMLファイルをオープンする
	def openFile(outputFilename)
		@outputFile = open(outputFilename, "w")
	end
	
	# 結果出力用のHTMLファイルをクローズする
	def closeFile()
		@outputFile.close();
	end
	
	# HTMLファイルの定型部分を書き込む
	# 引数には定型部分を書き込んだファイル名を渡す
	def putPhrase(phraseFilename)
		phraseFile = open(File::dirname(__FILE__)+"/"+phraseFilename, "r")
		phraseFile.each_line { |line|
			@outputFile.puts(line)
		}
		phraseFile.close()
	end
	
	def putPhraseString(phraseString)
		@outputFile.puts(phraseString)
	end
	
	BODY_IDENTICAL = 0	#変更なし
	BODY_CHANGED = 1	#変更
	BODY_ADDED = 2		#追加
	BODY_DELETED = 3	#削除
	BODY_IDENTICAL_BLANK = 4	#変更なし（ライン番号付与なし）
	BODY_CHANGED_BLANK = 5		#変更（ライン番号付与なし）
	BODY_ADDED_BLANK = 6		#追加（ライン番号付与なし）
	BODY_DELETED_BLANK = 7		#削除（ライン番号付与なし）
	# Diffの内容をHTMLファイルに書き込む
	# typeには上記定義を使用する
	def putBody(str, type)
		utfstr = NKF::nkf('-w', str)
		if type == BODY_IDENTICAL
			@outputFile.puts('<div class="linespan_i"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;">'+@srcLinenum.to_s+'</span><span class="identical">'+utfstr+'</span></div>')
			@srcLinenum += 1
		elsif type == BODY_CHANGED
			@outputFile.puts('<div class="linespan_c"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;">'+@srcLinenum.to_s+'</span><span class="changed">'+utfstr+'</span><span class="changed"></span></div>')
			@srcLinenum += 1
		elsif type == BODY_ADDED
			@outputFile.puts('<div class="linespan_a"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;">'+@srcLinenum.to_s+'</span><span class="added">'+utfstr+'</span></div>')
			@srcLinenum += 1
		elsif type == BODY_DELETED
			@outputFile.puts('<div class="linespan_c"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;">'+@srcLinenum.to_s+'</span><span class="deleted">'+utfstr+'</span><span class="changed"></span></div>')
			@srcLinenum += 1
		elsif type == BODY_IDENTICAL_BLANK
			@outputFile.puts('<div class="linespan_i"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;"></span><span class="identical">'+utfstr+'</span></div>')
		elsif type == BODY_CHANGED_BLANK
			@outputFile.puts('<div class="linespan_c"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;"></span><span class="changed">'+utfstr+'</span><span class="changed"></span></div>')
		elsif type == BODY_ADDED_BLANK
			@outputFile.puts('<div class="linespan_a"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;"></span><span class="added">'+utfstr+'</span></div>')
		elsif type == BODY_DELETED_BLANK
			@outputFile.puts('<div class="linespan_c"><span style="color:#808080; background-color:#F8F8F8; border-right-width:2px; border-right-style:groove; border-right-color:#E0E0E0;"></span><span class="deleted">'+utfstr+'</span><span class="changed"></span></div>')
		end
	end
	
	def putTag()
		@outputFile.puts('<a name="D'+@tagnum.to_s+'">')
		@tagnum += 1
	end
	
	def resetLineNum()
		@srcLinenum = 1
	end
end

resultHTML = ResultHTML.new()

resultHTML.openFile(ARGV[2])
srcFile = open(ARGV[0], "r")
diffFile = open(ARGV[1], "r")

# diffの総数を数える
diffNum = 0
diffFile.each_line { |line|
	if line =~ /^[1-9]+/
		diffNum += 1
	end
}

#
resultHTML.putPhrase("phrasetop0.txt")
resultHTML.putPhraseString("<title>"+File.basename(ARGV[0])+"</title>")
resultHTML.putPhrase("phrasetop1.txt")
resultHTML.putPhraseString("populate_combobox("+diffNum.to_s+");")
resultHTML.putPhrase("phrasetop2.txt")
#
# 変更前のソースコードの処理
#
diffFile.seek(0, IO::SEEK_SET)
srcLineNum = 1
diffFile.each_line { |line|
	if line =~ /^[1-9]+/
		if line =~ /[acd]/
			diffType = $&			# a(add),c(change),d(delete)のいずれかが入る
			tmpSrcLineCount = $`	# ライン数もしくはラインの範囲が入る
			tmpDstLineCount = $'	# ライン数もしくはラインの範囲が入る
			
			if (tmpSrcLineCount =~ /,/)
				diffSrcLineCount = $'.to_i - $`.to_i + 1	#diffに含まれる行数
				diffSrcLineNum = $`.to_i					#diffの始まりの行
			else
				diffSrcLineCount = 1
				diffSrcLineNum = tmpSrcLineCount.to_i
			end
			
			if (tmpDstLineCount =~ /,/)
				diffDstLineCount = $'.to_i - $`.to_i + 1
				diffDstLineNum = $`.to_i
			else
				diffDstLineCount = 1
				diffDstLineNum = tmpDstLineCount.to_i
			end

			#resultHTML.putBody("diffType = " + diffType, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffSrcLineCount = " + diffSrcLineCount.to_s, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffSrcLineNum = " + diffSrcLineNum.to_s, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffDstLineCount = " + diffDstLineCount.to_s, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffDstLineNum = " + diffDstLineNum.to_s, ResultHTML::BODY_IDENTICAL)

			if diffType == "a" #addの場合
				while srcLineNum < diffDstLineNum
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_IDENTICAL)
					srcLineNum += 1
				end
				
				resultHTML.putTag()
				i = 0
				while i < diffDstLineCount
					resultHTML.putBody("", ResultHTML::BODY_ADDED_BLANK)
					srcFile.gets
					srcLineNum += 1
					i += 1
				end
			elsif diffType == "d" #deleteの場合
				while srcLineNum <= diffDstLineNum
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_IDENTICAL)
					srcLineNum += 1
				end
				
				resultHTML.putTag()
				i = 0
				while i < diffSrcLineCount
					srcStrFromDiff = diffFile.gets
					srcStrFromDiff.slice!(0, 2)
					resultHTML.putBody(srcStrFromDiff, ResultHTML::BODY_DELETED)
					i += 1
				end
			elsif diffType == "c" #changeの場合
				while srcLineNum < diffDstLineNum
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_IDENTICAL)
					srcLineNum += 1
				end
				
				resultHTML.putTag()
				i = 0
				while i < diffSrcLineCount
					srcStrFromDiff = diffFile.gets
					srcStrFromDiff.slice!(0, 2)
					resultHTML.putBody(srcStrFromDiff, ResultHTML::BODY_CHANGED)
					i += 1
				end
				i = 0
				while i < diffDstLineCount
					srcFile.gets
					srcLineNum += 1
					i += 1
				end
				if diffSrcLineCount < diffDstLineCount
					i = 0
					while i < diffDstLineCount - diffSrcLineCount
						resultHTML.putBody("", ResultHTML::BODY_CHANGED_BLANK)
						i += 1
					end
				end
			end
		end
	end
}
srcFile.each_line { |line|
	resultHTML.putBody(line, ResultHTML::BODY_IDENTICAL)
}

resultHTML.putPhrase("phrasemiddle.txt")
resultHTML.resetLineNum

#
# 変更後のソースコードの処理
#
srcFile.seek(0, IO::SEEK_SET)
diffFile.seek(0, IO::SEEK_SET)
addCount = 0
delCount = 0
chgCount = 0
srcLineNum=1
diffFile.each_line { |line|
	if line =~ /^[1-9]+/
		if line =~ /[acd]/
			diffType = $&			# a(add),c(change),d(delete)のいずれかが入る
			tmpSrcLineCount = $`	# ライン数もしくはラインの範囲が入る
			tmpDstLineCount = $'	# ライン数もしくはラインの範囲が入る
			
			if (tmpSrcLineCount =~ /,/)
				diffSrcLineCount = $'.to_i - $`.to_i + 1	#diffに含まれる行数
				diffSrcLineNum = $`.to_i					#diffの始まりの行
			else
				diffSrcLineCount = 1
				diffSrcLineNum = tmpSrcLineCount.to_i
			end
			
			if (tmpDstLineCount =~ /,/)
				diffDstLineCount = $'.to_i - $`.to_i + 1
				diffDstLineNum = $`.to_i
			else
				diffDstLineCount = 1
				diffDstLineNum = tmpDstLineCount.to_i
			end

			#resultHTML.putBody("diffType = " + diffType, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffSrcLineCount = " + diffSrcLineCount.to_s, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffSrcLineNum = " + diffSrcLineNum.to_s, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffDstLineCount = " + diffDstLineCount.to_s, ResultHTML::BODY_IDENTICAL)
			#resultHTML.putBody("diffDstLineNum = " + diffDstLineNum.to_s, ResultHTML::BODY_IDENTICAL)

			if diffType == "a" #addの場合
				while srcLineNum < diffDstLineNum
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_IDENTICAL)
					srcLineNum += 1
				end
				
				resultHTML.putTag()
				i = 0
				while i < diffDstLineCount
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_ADDED)
					srcLineNum += 1
					i += 1
				end
				addCount += i
			elsif diffType == "d" #deleteの場合
				while srcLineNum <= diffDstLineNum
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_IDENTICAL)
					srcLineNum += 1
				end
				
				resultHTML.putTag()
				i = 0
				while i < diffSrcLineCount
					resultHTML.putBody("", ResultHTML::BODY_DELETED_BLANK)
					i += 1
				end
				delCount += i
			elsif diffType == "c" #changeの場合
				while srcLineNum < diffDstLineNum
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_IDENTICAL)
					srcLineNum += 1
				end
				
				resultHTML.putTag()
				i = 0
				while i < diffDstLineCount
					resultHTML.putBody(srcFile.gets, ResultHTML::BODY_CHANGED)
					srcLineNum += 1
					i += 1
				end
				chgCount += i
				if diffDstLineCount < diffSrcLineCount
					i = 0
					while i < diffSrcLineCount - diffDstLineCount
						resultHTML.putBody("", ResultHTML::BODY_CHANGED_BLANK)
						i += 1
					end
					chgCount += i
				end
			end
		end
	end
}
srcFile.each_line { |line|
	resultHTML.putBody(line, ResultHTML::BODY_IDENTICAL)
}

srcFile.close
diffFile.close

resultHTML.putPhrase("phrasebottom1.txt")
resultHTML.putPhraseString("<td><div><b>Summary:</b></div></td><td><div class=\"added\">ADD("+addCount.to_s+")</div></td><td><div class=\"deleted\">DELETE("+delCount.to_s+")</div></td><td><div class=\"changed\">CHANGE("+chgCount.to_s+")</div></td>")
resultHTML.putPhrase("phrasebottom2.txt")
resultHTML.closeFile()
