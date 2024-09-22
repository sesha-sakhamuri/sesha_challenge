package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"
)

func main() {
	var (
		reader   *bufio.Reader
		cardNums []string
		cardNum  string
		n        int
		err      error
	)

	reader = bufio.NewReader(os.Stdin)
	fmt.Scanf("%d\n", &n)

	for i := 0; i < n; i++ {
		cardNum, err = reader.ReadString('\n')
		if err != nil {
			fmt.Println("invalid delimiter")
			return
		}

		cardNums = append(cardNums, cardNum)
	}

	for _, cardNum := range cardNums {
		if validateCreditCardNumber(cardNum) {
			fmt.Println("valid")
		} else {
			fmt.Println("invalid")
		}
	}
}

func validateCreditCardNumber(cardNum string) bool {
	cardNum = strings.TrimSpace(cardNum)

	regexPattern := `^[456](\d{15}|\d{3}(-\d{4}){3})$`
	re := regexp.MustCompile(regexPattern)
	if !re.MatchString(cardNum) {
		return false
	}

	cardNum = strings.ReplaceAll(cardNum, "-", "")

	// validate if the card number has 4 or more consecutive repeated digits
	for i := 0; i < len(cardNum)-3; i++ {
		if cardNum[i] == cardNum[i+1] && cardNum[i] == cardNum[i+2] && cardNum[i] == cardNum[i+3] {
			return false
		}
	}

	return true
}
