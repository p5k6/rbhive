Gem::Specification.new do |s|
  s.name = "rbhive"
  s.version = "0.3.0"
  s.authors = ["Forward Internet Group", "Josh Stanfield"]
  s.date = %q{2013-06-18}
  s.description = "Simple lib for executing Hive queries, utilizing hiveserver2"
  s.summary = "Simple lib for executing Hive queries, utilizing hiveserver2"
  s.email = "p5k6@yahoo.com"
  s.files = [
    "lib/rbhive.rb",
    "lib/rbhive/connection.rb",
    "lib/rbhive/table_schema.rb",
    "lib/rbhive/result_set.rb",
    "lib/rbhive/explain_result.rb",
    "lib/rbhive/schema_definition.rb",
    "lib/thrift/facebook_service.rb",
    "lib/thrift/fb303_constants.rb",
    "lib/thrift/fb303_types.rb",
    "lib/thrift/hive_metastore_constants.rb",
    "lib/thrift/hive_metastore_types.rb",
    "lib/thrift/hive_service_constants.rb",
    "lib/thrift/hive_service_types.rb",
    "lib/thrift/queryplan_constants.rb",
    "lib/thrift/queryplan_types.rb",
    "lib/thrift/reflection_limited_constants.rb",
    "lib/thrift/reflection_limited_types.rb",
    "lib/thrift/serde_constants.rb",
    "lib/thrift/serde_types.rb",
    "lib/thrift/thrift_hive.rb",
    "lib/thrift/thrift_hive_metastore.rb"
  ]
  s.homepage = %q{http://github.com/p5k6/rbhive}
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.add_dependency('thrift', '>= 0.9.0')
  s.add_dependency('json')
end
