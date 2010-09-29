Then /^it should (not )?exit successfully$/ do |should_not|
    status = (should_not) ? be_false : be_true
    $?.exitstatus.zero?.should status
end
