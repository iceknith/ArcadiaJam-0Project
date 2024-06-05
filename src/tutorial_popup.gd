extends Control

var texts:Dictionary = {
	"intro": "Et me revoila dans ces souterrins de malheur...Enfer, il va bien falloir que je sorte d'ici 
	\n Mon vieux couteau me sera peut-être utile. C'est comment déja... <E> pour donner un coup ?",
	"mob": "Il va me falloir etre rapide pour échapper aux monstres. Bondir avec <Espace> peut etre une sollution...",
	"spell": "Un sort ! Les flèches dirrectionnelles me permettrons de m'en servir",
	"spell_use": "L'essence me permet de lancer des sorts, mais également de me protéger. Serait-il plus prudent de la conserver ?",
	"lowHealth": "Le couteau et le bond me vident mon esprit... Avec les monstres a gérer, je vai devoir etre prudente !"}

func change_text(new_text_type:String):
	$tutorial_text.visible = true
	$cressidia_icon.visible = true
	$tutorial_text.text = texts.get(new_text_type)
	$Timer.start()

func _on_timer_timeout():
	$tutorial_text.visible = false
	$cressidia_icon.visible = false
