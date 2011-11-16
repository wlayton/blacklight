To clone Blacklight and make a contribution to the project, follow these steps:
If you are a committer:
`git clone git@github.com:projectblacklight/blacklight.git`

Everyone else:
`git clone git://github.com/projectblacklight/blacklight.git`

Then prepare blacklight for testing:
```bash
cd blacklight
git submodule init && git submodule update
rake solr:marc:index_test_data RAILS_ENV=test
rake db:migrate
```

Now run the tests:
```bash
rake solr:spec
rake solr:features
```

Once you've made your changes on a branch and written tests for them,
make sure all the tests are passing again:
```bash
rake solr:spec
rake solr:features
```

If they pass go on to preparing your patch for submission.
