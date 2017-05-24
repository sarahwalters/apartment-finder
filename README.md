## Apartment finder
-------------------

Forked from [VikParuchuri/apartment-finder](https://github.com/VikParuchuri/apartment-finder).

This repo contains the code for a bot that will scrape Craigslist for real-time listings matching specific criteria, then alert you in Slack.  This will let you quickly see the best new listings, and contact the owners.  You can adjust the settings to change your price range, what neighborhoods you want to look in, and what transit stations and other points of interest you'd like to be close to.

Look in `settings.py` for a full list of all the configuration options.  Here's a high level overview:

* `MIN_PRICE` -- the minimum listing price you want to search for.
* `MAX_PRICE` -- the minimum listing price you want to search for.
* `BEDROOMS` -- the number of bedrooms you want to search for.
* `CRAIGSLIST_SITE` -- the regional Craigslist site you want to search in.
* `AREAS` -- a list of areas of the regional Craiglist site that you want to search in.
* `BOXES` -- coordinate boxes of the neighborhoods you want to look in.
* `NEIGHBORHOODS` -- if the listing doesn't have coordinates, a list of neighborhoods to match on.
* `MAX_TRANSIT_DISTANCE` -- the farthest you want to be from a transit station.
* `TRANSIT_STATIONS` -- the coordinates of transit stations.
* `CRAIGSLIST_HOUSING_SECTION` -- the subsection of Craigslist housing that you want to look in.
* `SLACK_CHANNEL` -- the Slack channel you want the bot to post in.

Read more about the original author's use of the tool [here](https://www.dataquest.io/blog/apartment-finding-slackbot/).

### External Setup
--------------------

Before using this bot, you'll need a Slack team, a channel for the bot to post into, and a Slack API key. If you're accessing an existing apartment-finder bot, these things already exist and you don't need to create them.

* Create a Slack team, which you can do [here](https://slack.com/create#email).
* Create a channel for the listings to be posted into.  [Here's](https://get.slack.help/hc/en-us/articles/201402297-Creating-a-channel) help on this. It's suggested to use `#housing` as the name of the channel.
* Get a Slack API token, which you can do [here](https://api.slack.com/docs/oauth-test-tokens).  [Here's](https://get.slack.help/hc/en-us/articles/215770388-Creating-and-regenerating-API-tokens) more information on the process.

### Running Locally
--------------------

#### Setting up your machine:
* Install Docker by following [these instructions](https://docs.docker.com/engine/installation/).
* Optionally: set yourself up for non-`sudo` Docker usage by adding yourself to the `docker` group. If you don't do this, you'll need to use `sudo` with all Docker commands.
    * `sudo groupadd docker`
    * `sudo gpasswd -a <USERNAME> docker` (replace <USERNAME> with your own username)
    * Log out and back in
    * `sudo service docker restart`
* Create a configuration directory in, or copy an existing configuration directory into, the `apartment-finder` directory. See "Configuration".

### Running the program:
* From the `apartment-finder` directory: `./bin/run.sh`

### Deploying to AWS
---------------------

#### Setting up a new EC2 instance:
* Launch an EC2 instance, following [these instructions](http://www.ybrikman.com/writing/2015/11/11/running-docker-aws-ground-up/#launching-an-ec2-instance) (just the "Launching an EC2 Instance" and "Installing Docker" sections).
    * Once you've run the "hello world" example, clean up: run `docker ps` to get the id of the `training/webapp` container, then `docker kill <CONTAINER-ID>` to kill the container.
* While still ssh'd into the instance, clone the apartment-finder repository:
    * `sudo yum install git`
    * `git clone https://github.com/sarahwalters/apartment-finder.git`
* Exit the instance. Then, copy a `config` directory into the instance (if you don't have a `config` directory yet, see "Configuration"):
    * scp -r -i <PATH-TO-EC2-KEY-PAIR.pem> <PATH-TO-CONFIG-DIRECTORY> ec2-user@<EC2-INSTANCE-PUBLIC-IP-ADDRESS>:~/apartment-finder/.

#### Accessing an existing EC2 instance:
You should've been given a key pair (extension `.pem`) and a public IP address for the existing EC2 instance.
* ssh into the instance: `ssh -i <PATH-TO-EC2-KEY-PAIR.pem> ec2-user@<EC2-INSTANCE-PUBLIC-IP-ADDRESS>`

#### Running the program:
* ssh into an EC2 instance, cd to the `apartment-finder` directory, then `./bin/run.sh`

### Configuration
--------------------

**If you've been given an existing config directory, you can skip these steps.**

Otherwise, to create a new config directory:
* `mkdir config`
* Create a file inside `config` called `private.py`.
    * `private.py` overrides `settings.py`. Use `private.py` to specify new values for any of the settings.
        * For example, you could put `AREAS = ['sfc']` in `private.py` to only look in San Francisco.
        * If you want to post into a Slack channel not called `housing`, add an entry for `SLACK_CHANNEL`.
        * If you don't want to look in the Bay Area, you'll need to update the following settings at the minimum:
            * `CRAIGSLIST_SITE`
            * `AREAS`
            * `BOXES`
            * `NEIGHBORHOODS`
            * `TRANSIT_STATIONS`
            * `CRAIGSLIST_HOUSING_SECTION`
            * `MIN_PRICE`
            * `MAX_PRICE`
* Create a file inside `config` called `credentials.list`.
    * Paste the following line into `credentials.list`: `SLACK_TOKEN=<token>`
    * Replace <token> with your Slack token (see "External Setup")

### Troubleshooting
---------------------

* Use `docker ps` to get the id of the container running the bot.
* Run `docker exec -it {YOUR_CONTAINER_ID} /bin/bash` to get a command shell inside the container.
* From the command shell inside the container:
    * Run `sqlite listings.db` to run the sqlite command line tool and inspect the database state (the only table is also called `listings`).
        * `select * from listings` will get all of the stored listings.
        * If nothing is in the database, you may need to wait for a bit, or verify that your settings aren't too restrictive and aren't finding any listings.
        * You can see how many listings are being found by looking at the logs.
    * Inspect the logs using `tail -f -n 1000 /opt/wwc/logs/afinder.log`.
