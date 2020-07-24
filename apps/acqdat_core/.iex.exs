# stup org

# stup projcct
# create gatwy

alias AcqdatCore.Schema.EntityManagement.{Organisation, Project}
alias AcqdatCore.Model.IotManager.Gateway
alias AcqdatCore.Repo
alias AcqdatCore.Schema.IotManager.Gateway, as: GSchema
alias AcqdatCore.Schema.IotManager.BrokerCredentials

[org | _] = Repo.all Organisation
[project | _] = Repo.all(Project)

gateway_params = %{name: "Gateway1", org_id: org.id, project_id: project.id,
        channel: "mqtt", parent_id: project.id, parent_type: "Project",
        access_token: "abcd1234"
      }

gateway_params2 = %{name: "Gateway2", org_id: org.id, project_id: project.id,
        channel: "mqtt", parent_id: project.id, parent_type: "Project",
        access_token: "abcd1234asdf"
      }
