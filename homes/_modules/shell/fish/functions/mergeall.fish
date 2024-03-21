for id in (gh pr list --jq '.[].number' --json number)
  gh pr merge $id --squash
  end;
