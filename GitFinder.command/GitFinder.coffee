#!/usr/local/bin/node

# GitFinder Widget
# Scan Finder window looking for Git projects and display statistics
# Dominique Da Silva (Nov 2014)
# https://github.com/atika/Ubersicht-GitFinder

# Nov 2017: Parse current XCode project and remove duplicates

# Execution time
# hrstart = process.hrtime();
# process.on "exit", ->
# 	hrend = process.hrtime(hrstart);
# 	console.log "Execution time (hr): %ds %dms", hrend[0], hrend[1]/1000000

{exec} = require 'child_process'
hash = require 'object-hash'

config = require './config.json'

String::count = (search) ->
	m = this.match new RegExp search.toString(), 'gm'
	c = if m then m.length else 0

String::extract = (regx, index) ->
	pattern = new RegExp regx.toString()
	if this.match pattern
		result = this.match pattern
		result[index]
	else
		0

String::capitalizeAll = ->
	this.replace /(^|\s)([a-z])/g, (m,p1,p2) ->
		p1+p2.toUpperCase()

Array::merge = (other) -> Array::push.apply @, other

exec '/usr/bin/osascript '+__dirname+'/FinderFolders.scpt', (error, stdout, stderr) ->

	paths = stdout.trim().split ','

	# Additional config.json paths
	additionals_paths = config.additionals_paths
	paths.merge(additionals_paths)

	parsedpath = 0
	data = {}
	gitrepos = []

	gitpaths = []

	if paths.length > 0
		# Filter Git folder and duplicates
		paths.forEach (p,i) ->
			thepath = p.trim()
			exec 'git rev-parse --show-toplevel', {cwd:thepath}, (error, stdout, stderr) ->
				if error is null
					gitpaths.push stdout.trim()
				parsedpath++
				if parsedpath is paths.length
					gitpaths = Array.from(new Set(gitpaths)) # remove duplicates

					# Parse each Git Paths
					parsedpath = 0
					gitpaths.forEach (g,j) ->
						gitpath = g.trim()

						exec 'git status >/dev/null 2>&1 && echo "$(git status -b --porcelain --ignored)" && echo "BRANCHES:$(git branch -v | wc -l | sed \'s/ //g\')" && echo "STASH:$(git stash list | wc -l | sed \'s/ //g\')"  && echo "SIZE:$(du -h -d0 |awk \'{print $1}\')"  && echo "NAME:$(basename \"$(git rev-parse --show-toplevel)\")" || exit 1;', {cwd:gitpath}, (error, stdout, stderr) ->
							GitStatus = stdout.trim()
							if error is null

								GitStatusInfo = GitStatus.split('\n')[0]
								#console.log "Git Infos: \n"+GitStatusInfo
								#console.log "Git Status:\n"+GitStatus
								repo =
									path: gitpath
									name: GitStatus.extract('NAME:(.*)$',1).replace(/[_-]+/g,' ').capitalizeAll()
									branch: GitStatusInfo.extract '## (([A-Za-z0-9-_]+)[.]{0,3})', 2
									remote: GitStatusInfo.extract '[.]{3}(\\S+)', 1
									ahead: GitStatusInfo.extract 'ahead (\\d+)', 1
									behind: GitStatusInfo.extract 'behind (\\d+)', 1
									branches: GitStatus.extract 'BRANCHES:(\\d)', 1
									stash: GitStatus.extract 'STASH:(\\d)', 1
									size: GitStatus.extract 'SIZE:(.*)', 1
									stats:
										added: GitStatus.count '^[AM]'
										modified: GitStatus.count '^ M'
										untracked: GitStatus.count '^\\?\\?'
										ignored: GitStatus.count '^!!'
									hash: ''

								repo['hash'] = hash repo.path
								gitrepos.push repo

							parsedpath++
							if parsedpath is gitpaths.length
								data.gitrepos = gitrepos
								data.prefs = config.prefs if config.prefs
								console.log JSON.stringify data
