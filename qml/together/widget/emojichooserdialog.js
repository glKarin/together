var emoji_list = [];
var emoji_name_list = [];

function Push(emoji, name)
{
	if(!emoji)
		return;

	emoji_list.push(emoji);
	emoji_name_list.push("[" + name + "]");
	Update();
}

function Pop()
{
	if(emoji_list.length === 0)
		return;
	emoji_list.pop();
	emoji_name_list.pop();
	Update();
}

function Clear()
{
	emoji_list = [];
	emoji_name_list = [];
	root.emojis = "";
	root.emojiNames = "";
}

function Update()
{
	root.emojis = emoji_list.join("");
	root.emojiNames = emoji_name_list.join("");
}
