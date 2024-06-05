extends Control

var texts:Dictionary = {
	"intro": "Et me revoila dans ces souterrains de malheur... Enfer, il va bien falloir que je sorte d'ici ! 
	\n Mon vieux couteau me sera sans doute utile. C'est comment déja... <E> pour donner un coup ?",
	"mob": "Il va me falloir courir vite pour échapper aux monstres. Bondir avec <Espace> peut être une sollution...",
	"spell": "Un sort ! Les flèches directionnelles me permettront de m'en servir.",
	"spell_use": "L'essence me permet de lancer des sorts, mais également de me protéger. Serait-il plus prudent de la conserver ?",
	"lowHealth": "Le couteau et le bond vident mon esprit... Avec les monstres à gérer, je vais devoir rester attentive !"}

func change_text(new_text_type:String):
	$tutorial_text.visible = true
	$cressidia_icon.visible = true
	$tutorial_text.text = texts.get(new_text_type)
	$Timer.start()

func _on_timer_timeout():
	$tutorial_text.visible = false
	$cressidia_icon.visible = false
