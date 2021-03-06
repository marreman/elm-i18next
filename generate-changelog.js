const { execSync } = require("child_process")

const tags = execSync("git tag").toString().trim().split("\n").reverse()

const firstCommit = execSync("git rev-list --max-parents=0 HEAD")
  .toString()
  .trim()

const changelog = tags
  .map((tag, index) => {
    const previousTag = tags[index + 1] ?? firstCommit
    const commits = execSync(`git log --oneline ${previousTag}..${tag}`)
      .toString()
      .trim()
      .split("\n")
      .map((commit) => `- ${commit}`)
      .join("\n")

    return `## ${tag}\n\n${commits}`
  })
  .join("\n\n")

process.stdout.write(changelog)
process.exit(0)
