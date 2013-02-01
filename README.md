# Joent dataset Stalker

Unofficial Joyent public dataset information from dataset api.

The informations are published to [https://twitter.com/DatasetStalker](https://twitter.com/DatasetStalker) (current status is closed beta.)


## Feature

- Tweet new dataset name and uuid.
- Tweet disappeared dataset name and uuid.

### Steps

perform every 1 hour following

1. create a staging list from [Joyent Public dataset API](https://datasets.joyent.com/datasets)
2. compare between the staging list and a current list.
3. tweet nothing but the current list.
4. tweet nothing but the staging list.
5. save the staging list as the current list.


## Plartforms

- Heroku [http://www.heroku.com/](http://www.heroku.com/)
- Redis to Go [http://redistogo.com/](http://redistogo.com/)
- Twitter [http://twitter.com](http://twitter.com)

## Modules

- Redis
- Rake
- Sidekiq
- Twitter
- Heroku Scheduler

## Deploy

Tweet your own twiiter account.

### What it is prepared

- heroku account
- Twitter OAUTH Token(Writeable)

#### Create app and add Heroku addons

<pre><code>heroku create
heroku addons:add redistogo:nano
heroku addons:add scheduler:standard</code></pre>

#### Add configrations as ENV

<pre><code>heroku config:add TWITTER_CONSUMER_KEY="YOUR_CONSUMER_KEY"
heroku config:add TWITTER_CONSUMER_SECRET="YOUR_CONSUMER_SECRET"
heroku config:add TWITTER_OAUTH_TOKEN="YOUR_OAUTH_TOKEN"
heroku config:add TWITTER_OAUTH_TOKEN_SECRET="YOUR_OAUTH_TOKEN_SECRET"</code></pre>

#### deploy to heroku and up worker dynos

<pre><code>git push heroku master
heroku ps:scale sidekiq=1</code></pre>

#### Add job to Heroku Scheduler
 
Add task `rake perform:heroku` at web console.

#### test

Connect your redis and use `spop current_sets` to remove one dataset.
Wait for tweet about deleted dataset as new dataset. Or manualy `heroku run rake perform:heroku`.

## Author

- [https://github.com/sawanoboly](https://github.com/sawanoboly) (HiganWorks LLC) 

## LICENSE

MIT [https://github.com/higanworks/LICENSES/tree/master/MIT](https://github.com/higanworks/LICENSES/tree/master/MIT)

