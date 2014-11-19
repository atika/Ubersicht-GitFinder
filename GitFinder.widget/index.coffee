# GitFinder Widget
# Scan Finder window looking for Git projects and display statistics
# Dominique Da Silva (Nov 2014)
# https://github.com/atika/Ubersicht-GitFinder

command: "/usr/local/bin/node /path/to/Ubersicht/Commands/GitFinder.command/GitFinder.js"

refreshFrequency: 10000

render: -> """
	<div id="repos"></div>
	<div class="footer">
		<div class="onoff"></div>
		<div class="checkin"></div>
	</div>
"""

style: """
width: 270px
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
		height:16px
		padding-bottom:4px
		margin-bottom: 7px
		position: relative
		border-bottom: solid 1px rgba(255,255,255,0.2)

		.title
			width: 170px
			padding: 2px
			position:absolute
			overflow: hidden
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

		.current, .sep, .remote
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

	.stash
		position: absolute
		top: 36px
		right: 10px
		padding:2px 18px 4px 2px
		background: url(GitFinder.widget/img/stack.svg) no-repeat no-repeat right 1px
		background-size: 16px auto
		border-radius: 5px
		border-bottom: solid 3px red

.footer
	width:100%
	position:relative
	margin: 0 10px
	.onoff
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
		.mark b
			color: #fb4807 !important

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

changeState: (isActive, domEl) ->
	if isActive
		$(".onoff",domEl).css("background-color","green")
	else
		$(".onoff",domEl).css("background-color","red")
		$(".repo",domEl).slideUp 300
		$(".checkin",domEl).html('GitFinder')

dataString: ""

update: (output, domEl) ->

	gitfinder = @
	storageKey = "GitFinder"
	isStopAvailable = if typeof @start is "function" then true else false
	hasNewThings = false

	$(".onoff",domEl).toggleClass('spin')

	# LOCALSTORAGE STORED KEYS
	try storedPrefs = JSON.parse(localStorage.getItem(storageKey))
	storedPrefs = {"isActive":true}  if storedPrefs is null or storedPrefs is "undefined"
		
	# BUTTON FOR ENABLE/DISABLE WIDGET
	$(".onoff").click ->
		if isStopAvailable
			if storedPrefs.isActive
				gitfinder.stop()
				storedPrefs.isActive = false 
			else 
				gitfinder.start()
				storedPrefs.isActive = true
		
			gitfinder.changeState(storedPrefs.isActive, domEl)
			localStorage.setItem(storageKey,JSON.stringify storedPrefs)
		else
			$(".checkin").html "Widget cannot be stopped<br> with this version of Ubersicht !"

	if isStopAvailable
		@changeState(storedPrefs.isActive, domEl)
		return false if storedPrefs.isActive is false # Return if widget are inactif

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

	# AUTO-FADE WIDGET
	needToFade = if $("#repos", domEl).css('opacity') is "1" then true else false
	if prefs.autoFade is true and hasNewThings is false and needToFade 
		autoFadeTimeout = setTimeout -> 
			$("#repos", domEl).animate {'opacity':'0.3'}, 800
		, parseInt(prefs.autoFadeTimeout - @refreshFrequency)

	# SET CHECK-IN DATE
	now = new Date()
	cheched_date = 'Checked at '+now.getHours()+':'+now.getMinutes()+':'+now.getSeconds()+''
	cheched_date += '<div class="mark"><b>Git</b>Finder</div>' if prefs.showMark
	$(".checkin", domEl).html cheched_date

	# BREAK HERE IF HAS NOTHING NEW TO UPDATE -------------------------------
	return 0 if hasNewThings is false

	# REPO ELEMENT TEMPLATE
	repoTpl = '
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
			</div>
			<div class="branch">
				<div class="current"></div>
				<div class="sep" style="display:none">&gt;</div><div class="remote" style="display:none"></div>
			</div>
			<div class="stash" style="display:none"></div>
		</div>
	'

	# POSITION OF THE WIDGET
	position = prefs.position.split("|")
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
	

	# Start Refresh Widget Elements
	$(domEl).find('#repos .repo').addClass('toRemove')

	for repo in repos
		if $('#'+repo.hash, domEl).length
			repoEl = $('#'+repo.hash, domEl)
			$(repoEl).removeClass('toRemove')
			isNew = false
		else
			repoEl = $(repoTpl).attr({id:repo.hash})
			isNew = true

		if prefs.statsAfter
			$('.branch',repoEl).insertAfter($('.head', repoEl)) 
		else
			$('.stats',repoEl).insertAfter($('.head', repoEl))

		$(".head .title a",repoEl).html(repo.name).attr 'href','finder://'+repo.path
		$(".branch .current",repoEl).html(repo.branch)

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

