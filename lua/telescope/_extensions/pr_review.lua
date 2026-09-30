local pr_review = require("pr_review")

return require("telescope").register_extension({
	exports = {
		pr_review = pr_review.pick,
	},
})
