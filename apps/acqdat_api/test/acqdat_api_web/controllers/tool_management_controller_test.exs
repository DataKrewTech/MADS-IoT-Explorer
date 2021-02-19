# defmodule AcqdatApiWeb.ToolManagementControllerTest do
#   use ExUnit.Case, async: true
#   use AcqdatApiWeb.ConnCase
#   use AcqdatCore.DataCase
#   import AcqdatCore.Support.Factory

#   describe "tool_transaction/2" do
#     setup :setup_conn

#     setup do
#       employee = insert(:employee)
#       tool_box = insert(:tool_box)
#       [employee: employee, tool_box: tool_box]
#     end

#     setup :tool_list

#     @tag tool_count: 2
#     test "fails if authorization header not found", %{conn: conn} do
#       bad_access_token = "avcbd123489u"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       result = result = conn |> post("/tl-mgmt/tool-transaction", %{}) |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end

#     @tag tool_count: 2
#     test "fails for bad params", context do
#       %{conn: conn} = context

#       result = conn |> post("/tl-mgmt/tool-transaction", %{}) |> json_response(400)

#       assert %{
#                "errors" => %{
#                  "tool_box_uuid" => ["can't be blank"],
#                  "tool_ids" => ["can't be blank"],
#                  "user_uuid" => ["can't be blank"]
#                },
#                "status" => "error"
#              } == result
#     end

#     @tag tool_count: 2
#     test "issue a list of tools", context do
#       %{tools: tools, employee: employee, tool_box: tool_box, conn: conn} = context

#       params = %{
#         "user_uuid" => employee.uuid,
#         "tool_box_uuid" => tool_box.uuid,
#         "tool_ids" => tool_uuid_list(tools),
#         "transaction" => "issue"
#       }

#       result = conn |> post("/tl-mgmt/tool-transaction", params) |> json_response(200)
#       assert %{"status" => "success", "data" => "transaction issue succeded"} == result
#     end

#     @tag tool_count: 2
#     test "error if non tool ids not found", context do
#       %{employee: employee, tool_box: tool_box, conn: conn} = context

#       params = %{
#         "user_uuid" => employee.uuid,
#         "tool_box_uuid" => tool_box.uuid,
#         "tool_ids" => ["1234", "abcd"],
#         "transaction" => "issue"
#       }

#       result = conn |> post("/tl-mgmt/tool-transaction", params) |> json_response(400)
#       assert %{"status" => "error", "errors" => "no issuable tools"} == result
#     end

#     @tag tool_count: 2
#     test "successfully return a list of tools", context do
#       %{tools: tools, employee: employee, tool_box: tool_box, conn: conn} = context

#       issue_params = %{
#         "user_uuid" => employee.uuid,
#         "tool_box_uuid" => tool_box.uuid,
#         "tool_ids" => tool_uuid_list(tools),
#         "transaction" => "issue"
#       }

#       # issue a list of tools
#       conn |> post("/tl-mgmt/tool-transaction", issue_params) |> json_response(200)

#       # return a list of tools
#       return_params = %{
#         "user_uuid" => employee.uuid,
#         "tool_box_uuid" => tool_box.uuid,
#         "tool_ids" => tool_uuid_list(tools),
#         "transaction" => "return"
#       }

#       result = conn |> post("/tl-mgmt/tool-transaction", return_params) |> json_response(200)
#       assert result == %{"data" => "transaction return succeded", "status" => "success"}
#     end

#     @tag tool_count: 2
#     test "error if no returnable tools found", context do
#       %{tools: tools, employee: employee, tool_box: tool_box, conn: conn} = context

#       issue_params = %{
#         "user_uuid" => employee.uuid,
#         "tool_box_uuid" => tool_box.uuid,
#         "tool_ids" => tool_uuid_list(tools),
#         "transaction" => "issue"
#       }

#       # issue a list of tools
#       conn |> post("/tl-mgmt/tool-transaction", issue_params) |> json_response(200)

#       # return a list of tools
#       return_params = %{
#         "user_uuid" => employee.uuid,
#         "tool_box_uuid" => tool_box.uuid,
#         "tool_ids" => ["abcd", "1234"],
#         "transaction" => "return"
#       }

#       result = conn |> post("/tl-mgmt/tool-transaction", return_params) |> json_response(400)
#       assert result == %{"status" => "error", "errors" => "no returnable tools"}
#     end
#   end

#   describe "list_employees/2" do
#     setup :employee_list
#     setup :setup_conn

#     @tag employee_count: 0
#     test "fails if authorization header not found", %{conn: conn} do
#       bad_access_token = "avcbd123489u"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       result = result = conn |> post("/tl-mgmt/employees", %{}) |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end

#     @tag employee_count: 2
#     test "returns a list of employees", context do
#       %{employees: employees, conn: conn} = context
#       params = %{factory_id: 123}
#       result = conn |> post("/tl-mgmt/employees", params) |> json_response(200)
#       assert length(result["employees"]) == length(employees)
#     end

#     @tag employee_count: 0
#     test "returns empty list if employees not found", context do
#       %{conn: conn} = context
#       params = %{factory_id: 123}
#       result = conn |> post("/tl-mgmt/employees", params) |> json_response(200)
#       assert result["employees"] == []
#     end
#   end

#   describe "verify_tools/2" do
#     setup :setup_conn

#     setup do
#       tool_box = insert(:tool_box)
#       [tool_box: tool_box]
#     end

#     setup :tool_list

#     @tag tool_count: 0
#     test "fails if authorization header not found", %{conn: conn} do
#       bad_access_token = "avcbd123489u"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       result = result = conn |> post("/tl-mgmt/verify-tool", %{}) |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end

#     @tag tool_count: 0
#     test "error if required params missing", context do
#       %{conn: conn} = context
#       params = %{}
#       result = conn |> post("/tl-mgmt/verify-tool", params) |> json_response(400)

#       assert result == %{
#                "errors" => %{
#                  "tool_box_uuid" => ["can't be blank"],
#                  "tool_uuid" => ["can't be blank"]
#                },
#                "status" => "error"
#              }
#     end

#     @tag tool_count: 1
#     test "error if tool not found", context do
#       %{conn: conn, tool_box: tool_box} = context
#       params = %{tool_uuid: "acb1", tool_box_uuid: tool_box.uuid}

#       result =
#         conn
#         |> post("/tl-mgmt/verify-tool", params)
#         |> json_response(401)

#       assert result == %{"errors" => "not found"}
#     end

#     @tag tool_count: 1
#     test "return tool if found", context do
#       %{conn: conn, tool_box: tool_box, tools: [tool]} = context
#       params = %{tool_uuid: tool.uuid, tool_box_uuid: tool_box.uuid}

#       result =
#         conn
#         |> post("/tl-mgmt/verify-tool", params)
#         |> json_response(200)

#       assert Map.has_key?(result["tool"], "name")
#       assert Map.has_key?(result["tool"], "status")
#       assert Map.has_key?(result["tool"], "uuid")
#     end
#   end

#   describe "employee_tool_status" do
#     setup :setup_conn

#     setup do
#       employee = insert(:employee)
#       tool_box = insert(:tool_box)
#       tool_issue_1 = insert(:tool_issue, employee: employee, tool_box: tool_box)
#       tool_issue_2 = insert(:tool_issue, employee: employee, tool_box: tool_box)
#       tool_issue_list = [tool_issue_1, tool_issue_2]

#       [employee: employee, tool_issue_list: tool_issue_list]
#     end

#     test "fails if authorization header not found", %{conn: conn} do
#       bad_access_token = "avcbd123489u"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       result =
#         result = conn |> post("/tl-mgmt/employee-tool-issue-status", %{}) |> json_response(403)

#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end

#     test "error if params misisng", context do
#       %{conn: conn} = context

#       params = %{}

#       result =
#         conn
#         |> post("/tl-mgmt/employee-tool-issue-status", params)
#         |> json_response(400)

#       assert result == %{
#                "errors" => %{"employee_uuid" => ["can't be blank"]},
#                "status" => "error"
#              }
#     end

#     test "returns error if employee not found", context do
#       %{conn: conn} = context

#       params = %{employee_uuid: "abc1234"}

#       result =
#         conn
#         |> post("/tl-mgmt/employee-tool-issue-status", params)
#         |> json_response(404)

#       assert result == %{"errors" => "not found"}
#     end

#     test "returns issued but not returned", context do
#       %{tool_issue_list: tool_issue_list, employee: employee, conn: conn} = context

#       [tool_issue_1, _tool_issue_2] = tool_issue_list

#       # return tool 1
#       tool_return(tool_issue_1)

#       params = %{employee_uuid: employee.uuid}

#       result =
#         conn
#         |> post("/tl-mgmt/employee-tool-issue-status", params)
#         |> json_response(200)

#       assert Map.has_key?(result, "tools")
#       assert length(result["tools"]) == 1
#     end

#     test "returns empty list if no issued tools with employee", context do
#       %{tool_issue_list: tool_issue_list, employee: employee, conn: conn} = context

#       [tool_issue_1, tool_issue_2] = tool_issue_list

#       # return tool 1
#       tool_return(tool_issue_1)
#       tool_return(tool_issue_2)

#       params = %{employee_uuid: employee.uuid}

#       result =
#         conn
#         |> post("/tl-mgmt/employee-tool-issue-status", params)
#         |> json_response(200)

#       assert Map.has_key?(result, "tools")
#       assert result["tools"] == []
#     end
#   end

#   describe "tool_box_status/2" do
#     setup :setup_conn

#     setup do
#       employee = insert(:employee)
#       tool_box = insert(:tool_box)

#       [employee: employee, tool_box: tool_box]
#     end

#     setup :tool_list

#     @tag tool_count: 0
#     test "fails if authorization header not found", %{conn: conn} do
#       bad_access_token = "avcbd123489u"

#       conn =
#         conn
#         |> put_req_header("authorization", "Bearer #{bad_access_token}")

#       result = result = conn |> post("/tl-mgmt/tool-box-status", %{}) |> json_response(403)
#       assert result == %{"detail" => "You are not allowed to perform this action.", "source" => nil, "status_code" => 403, "title" => "Unauthorized"}
#     end

#     @tag tool_count: 3
#     test "returns status of all tools in the tool box", context do
#       %{conn: conn, tool_box: tool_box} = context

#       params = %{tool_box_uuid: tool_box.uuid}
#       result = conn |> post("/tl-mgmt/tool-box-status", params) |> json_response(200)
#       assert Map.has_key?(result, "tools")
#       assert length(result["tools"]) == 3
#     end
#   end

#   defp tool_uuid_list(tools) do
#     Enum.map(tools, fn tool ->
#       tool.uuid
#     end)
#   end
# end
