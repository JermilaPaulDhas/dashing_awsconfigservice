SCHEDULER.every '1m', :first_in => 0 do

    require 'aws-sdk'
    require 'time'
    require 'yaml'
    
    # Add the regions that needs to be monitored
    regions = ["eu-west-1", "us-east-1"]
    nonCompliantResources = Array.new

    regions.each { |awsregion|
        count = 0
        awsconfigservice = Aws::ConfigService::Client.new(
            region: awsregion,
            access_key_id: access_key,
            secret_access_key: secret_key
        )

        resp = awsconfigservice.describe_config_rules()


        resp.config_rules.each do |rules|
            config_rule = rules.config_rule_name
            resources = awsconfigservice.get_compliance_details_by_config_rule({
                config_rule_name: config_rule,
                compliance_types: ["NON_COMPLIANT"],
            })

            resources.evaluation_results.each do |type_resource|
                count += 1
            end
        end
        nonCompliantResources.push region: awsregion, noncompliantcount: count
    }
    send_event("awsconfigservice", { noncompliantrules: nonCompliantResources})
end
