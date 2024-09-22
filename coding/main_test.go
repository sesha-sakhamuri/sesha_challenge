package main

import "testing"

func Test_validateCreditCardNumber(t *testing.T) {
	tests := []struct {
		name string
		card string
		want bool
	}{
		{
			name: "Valid Number",
			card: "4123456789123456",
			want: true,
		},
		{
			name: "Valid Number with hyphen",
			card: "6123-4567-8912-3456",
			want: true,
		},
		{
			name: "Valid Number with hyphen and trailing spaces",
			card: " 5123-4567-8912-3456 ",
			want: true,
		},
		{
			name: "Invalid first number",
			card: "9123-4567-8912-3456",
			want: false,
		},
		{
			name: "Invalid consecutive numbers",
			card: "9123-4567-8912-3333",
			want: false,
		},
		{
			name: "Invalid number",
			card: "9123-45-67-8912-3331",
			want: false,
		},
		{
			name: "Invalid cc number",
			card: " 9123-4567-8912-3331-3",
			want: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := validateCreditCardNumber(tt.card); got != tt.want {
				t.Errorf("validateCreditCardNumber() = %v, want %v", got, tt.want)
			}
		})
	}
}
