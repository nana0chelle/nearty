<?php

namespace App\Filament\Resources\Reports\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class ReportForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('user_id')
                    ->required()
                    ->numeric(),
                TextInput::make('reported_id')
                    ->required()
                    ->numeric(),
                TextInput::make('order_id')
                    ->numeric()
                    ->default(null),
                TextInput::make('reason')
                    ->required(),
                Textarea::make('description')
                    ->default(null)
                    ->columnSpanFull(),
                Select::make('status')
                    ->options(['pending' => 'Pending', 'resolved' => 'Resolved'])
                    ->default('pending')
                    ->required(),
            ]);
    }
}
