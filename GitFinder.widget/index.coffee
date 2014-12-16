# GitFinder Widget
# Scan Finder window looking for Git projects and display statistics
# Dominique Da Silva (Nov 2014)
# https://github.com/atika/Ubersicht-GitFinder
# Version v0.3

command: "/usr/local/bin/node /Users/path/to/Commands/GitFinder.command/GitFinder.js"

refreshFrequency: 15000

render: -> """
	<div id="repos"></div>
	<div class="footer">
		<div class="reload"></div>
		<div class="checkin"></div>
	</div>
"""

style: """
width: 280px
color: #FFF
font: 13px 'Helvetica'
-webkit-user-select: none
user-select: none

#repos
	width:100%

.repo
	width: 100%
	margin-bottom: 10px
	padding:10px 10px 2px 10px
	border-radius: 3px
	position:relative

	.head
		font-size: 14px
		width:100%
		float:left
		padding-bottom:4px
		margin-bottom: 7px
		position: relative
		border-bottom: solid 1px rgba(255,255,255,0.2)

		.title
			width: 55%
			padding: 2px
			overflow: hidden
			float:left
			a
				text-decoration: none
				color:inherit
			a:active
				color:#17959c

		.total, .ahead, .behind
			float: right
			font-size: 13px
			text-align: right
			margin: 2px 0 0 5px
			padding:0px 15px 1px 5px
		.ahead
			background: url(GitFinder.widget/img/arrow-up-right.svg) no-repeat right 1px
			background-size: 13px auto
		.behind
			background: url(GitFinder.widget/img/arrow-down-right.svg) no-repeat no-repeat right 1px
			background-size: 13px auto
		.total
			background: url(GitFinder.widget/img/shuffle.svg) no-repeat no-repeat right 1px
			background-size: 13px auto

	.branch
		margin-bottom: 5px
		position: relative
		background-color: rgba(#17959c,0.3)
		display: inline-block
		border-radius: 3px
		padding: 3px

		.current, .sep, .remote, .size
			border-radius: 4px
			padding:1px 5px
			float: left
		.sep
			background-color: rgba(#17959c, 0.6)
			margin: 0 2px
			color: #20b1b9
			font-weight: bold
			font-size: 14px
			padding:0 3px 2px 4px
		.remote
			color: #1fc1cb
		.size
			opacity:0.4
			padding:3px 2px 0 0
			font-size: 11px
	
	.stats
		display:inline-block
		font-size:14px
		margin-right: 35px

	.stats>div
		float: left
		border-radius: 3px
		background-color:rgba(255,255,255, 0.1)
		margin: 0 5px 4px 0
		text-align: center
	.stats .label
		border-radius: 3px 0 0 3px
		text-align: center
		font-weight: bold
		min-width: 15px
		padding: 1px 3px
		float:left
	.stats .count
		min-width: 15px
		padding: 1px 4px
		float: left
	.stats .added .label
		background-color: #79c725
		text-shadow: 1px 1px 1px rgba(#000,0.4)
	.stats .modified .label
		background-color: #b94d1c
		text-shadow: 1px 1px 1px rgba(#000,0.4)
	.stats .untracked .label
		background-color: #84acaa
		text-shadow: 1px 1px 1px rgba(#000,0.4)

	.stats .ignored
		opacity: 0.4	
	.stats .ignored .label
		background-color: rgba(#bc9180, 0.2)

	.stats .stash
		position: absolute
		right: 10px
		padding:0px 23px 3px 2px
		background: url(GitFinder.widget/img/stack.svg) no-repeat no-repeat 80% 0
		background-size: 16px auto
		background-color:none !important
		border-radius: 5px
		border-bottom: solid 3px red

.footer
	width:100%
	position:relative
	margin: 0 10px
	b
		color: #fc4907 !important
	.reload
		width:17px
		height:17px
		z-index:1000
		border-radius: 20px
		border: solid 3px rgba(#000,0.4)
		position: absolute
		margin-top: -5px
		left: 0
		background: url(GitFinder.widget/img/loop.svg) no-repeat no-repeat 3px 3px
		background-size: 11px auto
		opacity: 0.9
		
	.reload.off
		background: #fc4907 url(GitFinder.widget/img/git-logo.svg) no-repeat no-repeat 0px 0px
		width:20px
		height:20px
		background-size: 20px auto
		margin-top: -7px
		after:'toto'
	
	.checkin
		font-size: 10px
		font-weight: bold
		padding-left: 30px
		width: 97%
		opacity: 0.5
		text-transform: uppercase
		position: relative
		.mark
			position: absolute
			right: 0
			top: 0
			
	.spin
		animation: spin 2s ease-out 1 alternate

	.fade
		animation: fade 1s ease-in

	@keyframes spin
		0%
			background-color: rgba(255,255,255,0.2)
		50%
			background-color: rgba(#bdfe58,0.6)
		100% 
			transform: rotate(360deg)
			background-color: rgba(255,255,255,0.0)

	@keyframes fade
		0% 
			background-color: rgba(255,255,255,0.2)
		50%  
			background-color: rgba(#bdfe58,0.4)
		100% 
			background-color: rgba(255,255,255,0)

"""

dataString: ""

# REPO ELEMENT TEMPLATE
repoTemplate: """
<div class="repo" style="display:none">
	<div class="head">
		<div class="title"><a href="#" target="_blank"></a></div>
		<div class="total"></div>
		<div class="ahead"></div>
		<div class="behind"></div>
	</div>
	<div class="stats">
		<div class="added"><div class="label">A</div><div class="count"></div></div>
		<div class="modified"><div class="label">M</div><div class="count"></div></div>
		<div class="untracked"><div class="label">??</div><div class="count"></div></div>
		<div class="ignored"><div class="label">!!</div><div class="count"></div></div>
		<div class="stash" style="display:none"></div>
	</div>
	<div class="branch">
		<div class="current"></div>
		<div class="size" style="display:none"></div>
		<div class="sep" style="display:none">&gt;</div>
		<div class="remote" style="display:none"></div>
	</div>
		
	
</div>
"""

changeState: (isActive, domEl) ->
	if isActive
		$(".reload",domEl).removeClass('off')
		$(".reload",domEl).css("background-color","green")
	else
		# $(".reload",domEl).css("background-color","#fc4907")
		$(".reload",domEl).addClass('off')
		$("#repos",domEl).slideUp(400)
		$(".checkin",domEl).html('<b>Git</b>Finder')

isStopAvailable: ->
	if typeof @start is "function"
		return true 
	else 
		return false

storedPrefs: ->
	# LOCALSTORAGE STORED KEYS
	try storedPrefs = JSON.parse(localStorage.getItem("GitFinder"))
	storedPrefs = {"isActive":true}  if storedPrefs is null or storedPrefs is "undefined"
	return storedPrefs

afterRender: (domEl) ->
	
	gitfinder = @
	storedPrefs = gitfinder.storedPrefs()
	isStopAvailable = gitfinder.isStopAvailable()

	# BUTTON FOR ENABLE/DISABLE WIDGET REFRESH
	$(".footer").click ->
		if isStopAvailable
			if storedPrefs.isActive
				gitfinder.stop()
				gitfinder.dataString = ''
				storedPrefs.isActive = false 
			else 
				gitfinder.start()
				storedPrefs.isActive = true
		
			gitfinder.changeState(storedPrefs.isActive, domEl)
			localStorage.setItem("GitFinder",JSON.stringify storedPrefs)
		else
			$(".checkin").html "Widget cannot be stopped<br> with this version of Ubersicht !"

setPosition: (position, domEl) ->
	# POSITION OF THE WIDGET
	position = position.split("|")
	switch position[0]
		when "TL"
			$(domEl).css({'left':parseInt(position[1]),'top':parseInt(position[2])})
		when "TR"
			$(domEl).css({'right':parseInt(position[1]),'top':parseInt(position[2])})
		when "BR"
			$(domEl).css({'right':parseInt(position[1]),'bottom':parseInt(position[2])})
		when "C"
			$(domEl).css({'left':$(window).width()/2-$(domEl).width()/2,'top':$(window).height()/2-50})
		else
			$(domEl).css({'left':parseInt(position[1]),'bottom':parseInt(position[2])})

update: (output, domEl) ->

	gitfinder = @
	hasNewThings = false
	storedPrefs = @storedPrefs()
	isStopAvailable = gitfinder.isStopAvailable()

	if output.length > 0 
		if @dataString is output
			# Nothing new
			hasNewThings = false
		else
			# New data, need update
			hasNewThings = true
			$("#repos",domEl).animate({'opacity':1.0}, 800)

		@dataString = output
		data = JSON.parse output
		repos = data.gitrepos
		prefs = data.prefs
	else 
		return 1

	# Update widget position
	gitfinder.setPosition prefs.position, domEl if hasNewThings

	# Return and stop here if widget has set to inactif
	if isStopAvailable is true
		if storedPrefs.isActive is false 
			gitfinder.stop()
			gitfinder.dataString = ''
			@changeState(false, domEl)
			return false 

	$(".reload",domEl).toggleClass('spin')

	# AUTO-FADE WIDGET
	needToFade = if $("#repos", domEl).css('opacity') is "1" then true else false
	if prefs.autoFade is true and hasNewThings is false and needToFade 
		autoFadeTimeout = setTimeout -> 
			$("#repos", domEl).animate {'opacity':'0.3'}, 800
		, parseInt(prefs.autoFadeTimeout - @refreshFrequency)

	# SET CHECK-IN DATE
	now = new Date()
	checked_date = 'Checked at '+now.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, "$1")
	checked_date += '<div class="mark"><b>Git</b>Finder</div>' if prefs.showMark
	$(".checkin", domEl).html checked_date


	# BREAK HERE IF HAS NOTHING NEW TO UPDATE -------------------------------
	return 0 if hasNewThings is false


	# START REFRESH WIDGET ELEMENTS
	$(domEl).find('#repos .repo').addClass('toRemove')

	for repo in repos
		if $('#'+repo.hash, domEl).length
			repoEl = $('#'+repo.hash, domEl)
			$(repoEl).removeClass('toRemove')
			isNew = false
		else
			repoEl = $(@repoTemplate).attr({id:repo.hash})
			isNew = true

		if prefs.statsAfter
			$('.branch',repoEl).insertAfter($('.head', repoEl)) 
		else
			$('.stats',repoEl).insertAfter($('.head', repoEl))

		$(".head .title a",repoEl).html(repo.name).attr 'href','file://'+repo.path
		# $(".head .title a",repoEl).html(repo.name).bind 'click', ->
		# 	$(window).open('file://'+repo.path)
		$(".branch .current",repoEl).html(repo.branch)
		$(".branch .size",repoEl).html(repo.size).show() if prefs.showSize

		remoteEl = $(".branch .remote", repoEl)
		sepEl = $(".branch .sep", repoEl)

		if repo.remote.length	
			remoteEl.html repo.remote; 
			$(remoteEl).fadeIn() 
			$(sepEl).fadeIn() 
		else 
			$(remoteEl).fadeOut()	
			$(sepEl).fadeOut()	

		$(".head .total",repoEl).html(repo.branches)
		$(".head .ahead",repoEl).html(repo.ahead)
		$(".head .behind",repoEl).html(repo.behind)

		if repo.stash > 0
			$(".stash",repoEl).html(repo.stash).fadeIn()
		else
			$(".stash",repoEl).fadeOut(200)

		# Git Statistics
		$(".stats .added .count",repoEl).html(repo.stats.added)
		$(".stats .modified .count",repoEl).html(repo.stats.modified)
		$(".stats .untracked .count",repoEl).html(repo.stats.untracked)
		$(".stats .ignored .count",repoEl).html(repo.stats.ignored)

		if isNew
			$("#repos",domEl).append(repoEl); 
			$(repoEl).fadeIn(500).css("animation","fade 1s ease-in")

	$(".toRemove", domEl).slideUp 300, ->
			$(this).remove()

	# REPO BLOCK STYLE
	$(".repo",domEl).css(prefs.backStyle) if typeof prefs.backStyle is "object" and prefs.applyBackStyle

	# SHOW-HIDE IGNORED
	if prefs.showIgnored then $(".stats .ignored",domEl).show() else $(".stats .ignored",domEl).hide()

	# STATS BIGGER
	if prefs.statsBigger
		$(".stats .label, .stats .count", domEl).css({"font-size":"22px", "padding":"3px 10px"})
		$("#repos", domEl).css("width":"320px")
	else
		$(".stats div", domEl).css({"font-size":"", "padding":""})
		$("#repos", domEl).css("width":"")

