data "aws_ami" "test_data_ami"{
    most_recent = true
    owners = ["801119661308"]
    
    filter{
        name = "name"
        values = ["Windows_Server-2019-English-Full-Base-*"]
    }
}