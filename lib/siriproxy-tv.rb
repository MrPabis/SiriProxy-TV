# -*- encoding: utf-8 -*-
require 'cora'
require 'siri_objects'
require 'eat'
require 'nokogiri'
require 'timeout'


#######
#
# This is a simple XML parsing Plugin for Austrian DVB-T Television Channels
# and can easily be adoptet for German channels.
# sorry for the strange code - im just learning Ruby :-)
#
# Remember to add the plugin to the "./siriproxy/config.yml" file!
#
######
#
# Das ist ein einfaches TV Programm plugin, welches die aktuellen österreichischen
# Sendungen DVB-T Kanäle vorliest
# Kann auch einfach für die deutschen Kanäle angepasst werden (siehe 3SAT)
#
# ladet das Plugin in der "./siriproxy/config.yml" datei !
#
########
## ## ## WIE ES FUNKTIONIERT
#
## # Was spielt es jetzt?
#
# sagt einfach einen Satz mit "TV" + "Programm" für eine komplette Ansage
# oder "Programm" + Sendername für eine spezifische Abfrage
#
## # Was spielt es Abends (20:15)
#
# "TV" + "Abend" oder "Primetime" für das komplette Hauptabendprogramm
#
#
# bei Fragen Twitter: @Muhkuh0815
# oder github.com/muhkuh0815/SiriProxy-TV
# Video Vorschau: http://www.youtube.com/watch?v=mTi9EC0M6Hw
#
#### ToDo
#
# Zeitabfrage - wie lange die sendung noch läuft
# bei spezifischer Abfrage - aktuelle + 2 folgende Sendungen
# Info Abfrage für Sendungsbeschreibung
#
######

class SiriProxy::Plugin::TV < SiriProxy::Plugin
        
    def initialize(config)
        #if you have custom configuration options, process them here!
    end
    def doc
    end
    def docs
    end
    def dob
    end
 
 
 def tvprogramm(doc) # reading whats playing now - Austrian channels
    begin
    doc = Nokogiri::XML(eat("http://www.texxas.de/tv/hauptsenderJetzt.xml"))
    return doc
    rescue
      doc = ""
    end
 end
 
 def tvprogrammabend(doc) # reading whats playing in the evening (20:15) - Austrian channels
  begin
    doc = Nokogiri::XML(eat("http://www.texxas.de/tv/hauptsender.xml"))
    return doc
    rescue
      doc = ""
    end
 end
 
 def tvprogrammsat(dob) # reading whats playing now - 3SAT
   begin
    dob = Nokogiri::XML(eat("http://www.texxas.de/tv/spartensenderJetzt.xml"))
  return dob
    rescue
     dob = ""
    end
 end
 
 def tvprogrammsatabend(dob) # reading whats playing in the evening (20:15) - 3SAT
   begin
    dob = Nokogiri::XML(eat("http://www.texxas.de/tv/spartensender.xml"))
  return dob
    rescue
     dob = ""
    end
 end
 
 def cleanup(doc)
  doc = doc.gsub(/<\/?[^>]*>/, "")
  return doc
 end
 
 def dosund(dos)
  if dos["&amp;"]
  dos["&amp;"] = "&"
    end
    return dos
 end
 
# TV Programm Abend - TV Programm Evening - all channels
def abendprogramm
doc = tvprogrammabend(doc)
dob = tvprogrammsatabend(dob)
    if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    elsif dob == NIL or dob == ""
    say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
     doc.encoding = 'utf-8'
     dob.encoding = 'utf-8'
        docs = doc.xpath('//title')
        dobs = dob.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
          doss = dos[0,5]
         if doss == "ARD: "
         dos = dosund(dos)
         orf1 = dos
         elsif doss == "ZDF: "
         dos = dosund(dos)
         orf2 = dos
         elsif doss == "SAT.1"
         dos = dosund(dos)
            orf3 = dos
         elsif doss == "RTL: "
         dos = dosund(dos)
         atv = dos
         elsif doss == "PRO7:"
         dos = dosund(dos)
         orfs = dos
         elsif doss == "RTL2:"
         dos = dosund(dos)
         puls4 = dos
         elsif doss == "KABEL"
         dos = dosund(dos)
         servus = dos
         else
         end
         i += 1
        end
        i = 1
        while i < dobs.length
         dos = dobs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
        
         if doss == "3SAT:"
         dos = dosund(dos)
         sat = dos
         else
         end
         i += 1
        end
         say "", spoken: "Programm für 20 Uhr 15"
            object = SiriAddViews.new
     object.make_root(last_ref_id)
     answer = SiriAnswer.new("TV Programm - 20:15", [
     SiriAnswerLine.new(orf1),
     SiriAnswerLine.new(orf2),
     SiriAnswerLine.new(orf3),
     SiriAnswerLine.new(atv),
     SiriAnswerLine.new(sat),
     SiriAnswerLine.new(puls4),
     SiriAnswerLine.new(servus),
     SiriAnswerLine.new(orfs)
     ])
     object.views << SiriAnswerSnippet.new([answer])
     send_object object
        end
    request_completed
end

# TV Programm jetzt - TV Programm NOW all channels
def programmjetzt
doc = tvprogramm(doc)
dob = tvprogrammsat(dob)
    if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    elsif dob == NIL or dob == ""
    say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        dob.encoding = 'utf-8'
        docs = doc.xpath('//title')
        dobs = dob.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
          doss = dos[0,5]
         if doss == "ARD: "
         dos = dosund(dos)
         orf1 = dos
         elsif doss == "ZDF: "
         dos = dosund(dos)
         orf2 = dos
         elsif doss == "SAT.1"
         dos = dosund(dos)
            orf3 = dos
         elsif doss == "RTL: "
         dos = dosund(dos)
         atv = dos
         elsif doss == "PRO7:"
         dos = dosund(dos)
         orfs = dos
         elsif doss == "RTL2:"
         dos = dosund(dos)
         puls4 = dos
         elsif doss == "KABEL"
         dos = dosund(dos)
         servus = dos
         else
         end
         i += 1
        end
        i = 1
        while i < dobs.length
         dos = dobs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
        
         if doss == "3SAT:"
         dos = dosund(dos)
         sat = dos
         else
         end
         i += 1
        end
          say "", spoken: "Das läuft gerade im Fernsehen"
object = SiriAddViews.new
     object.make_root(last_ref_id)
     answer = SiriAnswer.new("TV Programm - aktuell", [
     SiriAnswerLine.new(orf1),
     SiriAnswerLine.new(orf2),
     SiriAnswerLine.new(orf3),
     SiriAnswerLine.new(atv),
     SiriAnswerLine.new(sat),
     SiriAnswerLine.new(puls4),
     SiriAnswerLine.new(servus),
     SiriAnswerLine.new(orfs)
     ])
     object.views << SiriAnswerSnippet.new([answer])
     send_object object
      
        end
    request_completed
end

def askformore
		response = ask "Möchtest du außerdem sehen was sonst noch läuft?" #ask the user for something
		if(response =~ /Ja/i) #process their response
			say "Alles klar!"
			programmjetzt
		end
end
listen_for /(TV|spielt|spielers|Was läuft heute).*(Crime Time|kleinteilen|Abend)/i do
	abendprogramm
end

listen_for /(TV|spielt|spielers).*(Programm|Fernsehen)/i do
	programmjetzt
end

# RTL now
listen_for /(spiel|spieles|spielt|TV|Programm|Was läuft auf).*(RTL)/i do
doc = tvprogramm(dob)
if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        docs = doc.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
         if doss == "RTL: "
         dos = dosund(dos)
         sat = dos
         end
         i += 1
        end
		say "Hier ist dein Ergebnis:", spoken: "Hier ist dein Ergebnis"
		object = SiriAddViews.new
		object.make_root(last_ref_id)
		answer = SiriAnswer.new("Jetzt:", [
		SiriAnswerLine.new(sat)
		])
		object.views << SiriAnswerSnippet.new([answer])
		
		send_object object
		############
		askformore
		end
			 request_completed
        end

# RTL2 now
listen_for /(spiel|spieles|spielt|TV|Programm|Was läuft auf).*(RTL2|RTL zwei)/i do
doc = tvprogramm(dob)
if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        docs = doc.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
         if doss == "RTL2:"
         dos = dosund(dos)
         sat = dos
         end
         i += 1
        end
		say "Hier ist dein Ergebnis:", spoken: "Hier ist dein Ergebnis"
		object = SiriAddViews.new
		object.make_root(last_ref_id)
		answer = SiriAnswer.new("Jetzt:", [
		SiriAnswerLine.new(sat)
		])
		object.views << SiriAnswerSnippet.new([answer])
		
		send_object object
		############
		askformore
		end
			 request_completed
end

# SAT.1 now
listen_for /(spiel|spieles|spielt|TV|Programm|Was läuft auf).*(SAT1|SAT ein|satt eins)/i do
doc = tvprogramm(dob)
if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        docs = doc.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
         if doss == "SAT.1"
         dos = dosund(dos)
         sat = dos
         end
         i += 1
        end
		say "Hier ist dein Ergebnis:", spoken: "Hier ist dein Ergebnis"
		object = SiriAddViews.new
		object.make_root(last_ref_id)
		answer = SiriAnswer.new("Jetzt:", [
		SiriAnswerLine.new(sat)
		])
		object.views << SiriAnswerSnippet.new([answer])
		
		send_object object
		############
		askformore
		end
			 request_completed
end

# VOX now
listen_for /(spiel|spieles|spielt|TV|Programm|Was läuft auf).*(VOX|rocks)/i do
doc = tvprogramm(dob)
if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        docs = doc.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
         if doss == "VOX: "
         dos = dosund(dos)
         sat = dos
         end
         i += 1
        end
		say "Hier ist dein Ergebnis:", spoken: "Hier ist dein Ergebnis"
		object = SiriAddViews.new
		object.make_root(last_ref_id)
		answer = SiriAnswer.new("Jetzt:", [
		SiriAnswerLine.new(sat)
		])
		object.views << SiriAnswerSnippet.new([answer])
		
		send_object object
		############
		askformore
		end
			 request_completed
end

# ARD now
listen_for /(spiel|spieles|spielt|TV|Programm|Was läuft auf).*(ARD)/i do
doc = tvprogramm(dob)
if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        docs = doc.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
         if doss == "ARD: "
         dos = dosund(dos)
         sat = dos
         end
         i += 1
        end
		say "Hier ist dein Ergebnis:", spoken: "Hier ist dein Ergebnis"
		object = SiriAddViews.new
		object.make_root(last_ref_id)
		answer = SiriAnswer.new("Jetzt:", [
		SiriAnswerLine.new(sat)
		])
		object.views << SiriAnswerSnippet.new([answer])
		
		send_object object
		############
		askformore
		end
			 request_completed
end

# ZDF now
listen_for /(spiel|spieles|spielt|TV|Programm|Was läuft auf).*(ZDF)/i do
doc = tvprogramm(dob)
if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        docs = doc.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
         if doss == "ZDF: "
         dos = dosund(dos)
         sat = dos
         end
         i += 1
        end
		say "Hier ist dein Ergebnis:", spoken: "Hier ist dein Ergebnis"
		object = SiriAddViews.new
		object.make_root(last_ref_id)
		answer = SiriAnswer.new("Jetzt:", [
		SiriAnswerLine.new(sat)
		])
		object.views << SiriAnswerSnippet.new([answer])
		
		send_object object
		############
		askformore
		end
			 request_completed
end

# 3SAT now
listen_for /(spiel|spieles|spielt|TV|Programm|Was läuft auf).*(3 Sat|drei SAT|dreisatz|3sat)/i do
doc = tvprogrammsat(dob)
if doc == NIL or doc == ""
        say "Es gab ein Problem beim Einlesen des Fernsehprogramms!"
    else
        doc.encoding = 'utf-8'
        docs = doc.xpath('//title')
        i = 1
        while i < docs.length
         dos = docs[i].to_s
          dos = cleanup(dos)
         doss = dos[0,5]
         if doss == "3SAT:"
         dos = dosund(dos)
         sat = dos
         end
         i += 1
        end
            say "Es spielt gerade auf", spoken: "Es spielt gerade auf,"
            say sat
        end
    request_completed
end
end