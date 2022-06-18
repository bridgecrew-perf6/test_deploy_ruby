module InvoicesHelper
	def terbilang (bilangan)
		bilangan = bilangan.abs
		angka = ["", "Satu", "Dua", "Tiga", "Empat", "Lima", "Enam", "Tujuh", "Delapan", "Sembilan", "Sepuluh", "Sebelas"]

		temp = ""

		if bilangan < 12
			temp = " " + angka[bilangan]
		elsif bilangan < 20
			temp = terbilang(bilangan - 10) + " belas"
		elsif bilangan < 100
			temp = terbilang(bilangan / 10) + " puluh" + terbilang(bilangan % 10)
		elsif bilangan < 200
			temp = " seratus" + terbilang(bilangan - 100)
		elsif bilangan < 1000
			temp = terbilang(bilangan / 100) + " ratus" + terbilang(bilangan % 100)
		elsif bilangan < 2000
			temp = " seribu" + terbilang(bilangan - 1000)
		elsif bilangan < 1000000
 			temp = terbilang(bilangan / 1000) + " ribu" + terbilang(bilangan % 1000)
 		elsif bilangan < 1000000000
 			temp = terbilang(bilangan / 1000000) + " juta" + terbilang(bilangan % 1000000)
		end

		return temp
	end
end
